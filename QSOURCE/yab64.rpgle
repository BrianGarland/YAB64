**FREE



/INCLUDE yab64_h.rpgle



// iconv prototypes and data structure templates
DCL-PR iconv_open LIKE(iconv_t) EXTPROC('QtqIconvOpen');
    ToCode   LIKEDS(qtqcode_t) CONST;
    FromCode LIKEDS(qtqcode_t) CONST;
END-PR;

DCL-PR iconv UNS(10) EXTPROC('iconv');
    cd           LIKE(iconv_t) VALUE;
    InputBuffer  POINTER;
    InputBytes   UNS(10);
    OutputBuffer POINTER;
    OutputBytes  UNS(10);
END-PR;

DCL-PR iconv_close INT(10) EXTPROC('iconv_close');
    cd LIKE(iconv_t) VALUE;
END-PR;

DCL-DS iconv_t QUALIFIED TEMPLATE;
    return_value INT(10);
    cd           INT(10) DIM(12);
END-DS;

DCL-DS qtqcode_t QUALIFIED TEMPLATE;
    CCSID                   INT(10) INZ(0);               
    ConversionAlternative   INT(10) INZ(0);
    SubstitutionAlternative INT(10) INZ(0);               
    ShiftStateAlternative   INT(10) INZ(0);               
    InputLengthOption       INT(10) INZ(0);               
    ErrorOption             INT(10) INZ(0);               
    Reserved                CHAR(8) INZ(*LOVAL)       
END-DS;



//------------------------------------------------------------------------------
// Procedure
//     YAB64_Encode
//
// Description
//     Base64 encode a character string
//
// Parameters
//     Input     - string to encode
//     InputLen  - length of input string
//     Output    - encoded string
//     OutputLen - length of encoded string
//     URLEncode - TRUE/FALSE Use URL safe encoding
//                 (optional, defaults to FALSE)
//
// Return Value
//     None
//
//------------------------------------------------------------------------------
DCL-PROC YAB64_Encode EXPORT;
    DCL-PI *N;
        Input     LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
        InputLen  UNS(5) CONST;
        Output    LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
        OutputLen UNS(5);
        URLEncode IND OPTIONS(*NOPASS);
    END-PI;

    DCL-DS *N;
        AsciiChar CHAR(1);
        AsciiNum  UNS(3) POS(1);
    END-DS;

    DCL-DS iconv_from LIKEDS(qtqcode_t);
    DCL-DS iconv_to   LIKEDS(qtqcode_t);

    DCL-S Alphabet     CHAR(64);
    DCL-S AsciiString  LIKE(LongString);
    DCL-S AsciiPtr     POINTER INZ(%ADDR(AsciiString));
    DCL-S AsciiLen     UNS(10);
    DCL-S Binary       CHAR(8);
    DCL-S BinaryString VARCHAR(1000000);
    DCL-S EbcdicString LIKE(LongString);
    DCL-S EbcdicPtr    POINTER INZ(%ADDR(EbcdicString));
    DCL-S EbcdicLen    UNS(10);
    DCL-S i            INT(5);
    DCL-S Output1      VARCHAR(MAX_LENGTH);
    DCL-S Remainder    INT(5);


    Output = '';
    OutputLen = 0;

    IF %PARMS >= %PARMNUM(urlEncode) AND urlEncode;
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    ELSE;
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    ENDIF;

    EbcdicString = Input;
    EbcdicLen    = InputLen;
    AsciiString  = '';
    AsciiLen     = MAX_LENGTH;

    iconv_from.ccsid = 37;
    iconv_to.ccsid = 819;
    iconv_table = iconv_open(iconv_to:iconv_from);
    iconv(iconv_table:EbcdicPtr:EbcdicLen:AsciiPtr:AsciiLen);
    iconv_close(iconv_table);

    FOR i = 1 TO InputLen;
        AsciiChar = %SUBST(AsciiString:i:1);
        Binary = ToBinary(AsciiNum);
        BinaryString += Binary;
    ENDFOR;

    // Make sure the length is a multiple of 6
    Remainder = %REM(%LEN(BinaryString):6);
    IF Remainder <> 0;
        FOR i = 1 TO 6-Remainder;
            BinaryString += '0';
        ENDFOR;
    ENDIF;

    FOR i = 1 TO %LEN(BinaryString) BY 6;
        AsciiNum = ToDecimal(%SUBST(BinaryString:i:6));
        Output1 += %SUBST(Alphabet:AsciiNum+1:1);
        OutputLen += 1;
    ENDFOR;

    // Make sure the length is a multiple of 4
    Remainder = %REM(OutputLen:4);
    IF Remainder <> 0;
        FOR i = 1 TO 4-Remainder;
            Output1 += '=';
            OutputLen += 1;
        ENDFOR;
    ENDIF;

    Output = Output1;

    RETURN;

END-PROC;



//------------------------------------------------------------------------------
// Procedure
//     YAB64_Decode
//
// Description
//     Decode a BASE64 character string
//
// Parameters
//     Input     - string to decode
//     InputLen  - length of input string
//     Output    - decoded string
//     OutputLen - length of decoded string
//     URLEncode - TRUE/FALSE Use URL safe encoding
//                 (optional, defaults to FALSE)
//
// Return Value
//     None
//
//------------------------------------------------------------------------------
DCL-PROC YAB64_Decode EXPORT;
    DCL-PI *N;
        Input     LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
        InputLen  UNS(5) CONST;
        Output    LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
        OutputLen UNS(5);
        URLEncode IND OPTIONS(*NOPASS);
    END-PI;

    DCL-DS *N;
        AsciiChar CHAR(1);
        AsciiNum  UNS(3) POS(1);
    END-DS;

    DCL-DS iconv_from LIKEDS(qtqcode_t);
    DCL-DS iconv_to   LIKEDS(qtqcode_t);

    DCL-S Alphabet     CHAR(64);
    DCL-S AsciiString  LIKE(LongString);
    DCL-S AsciiPtr     POINTER INZ(%ADDR(AsciiString));
    DCL-S AsciiLen     UNS(10);
    DCL-S Binary1      CHAR(6) DIM(MAX_LENGTH);
    DCL-S EbcdicString LIKE(LongString);
    DCL-S EbcdicPtr    POINTER INZ(%ADDR(EbcdicString));
    DCL-S EbcdicLen    UNS(10);
    DCL-S i            INT(5);
    DCL-S Indexes1     ZONED(2:0) DIM(MAX_LENGTH);
    DCL-S NumChars     INT(5);
    DCL-S Output1      VARCHAR(MAX_LENGTH);
    DCL-S OutputBinary VARCHAR(1000000);


    Output = '';
    OutputLen = 0;

    IF %PARMS >= %PARMNUM(urlEncode) AND urlEncode;
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    ELSE;
        Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    ENDIF;

    // Ingore any = characters that padd the string
    FOR i = 1 TO InputLen;
        IF %SUBST(Input:i:1) = '=';
            LEAVE;
        ENDIF;
        Indexes1(i) = %SCAN(%SUBST(Input:i:1):Alphabet) - 1;
        NumChars += 1;
    ENDFOR;

    FOR i = 1 TO NumChars;
        EVALR Binary1(i) = ToBinary(Indexes1(i));
        OutputBinary += Binary1(i);
    ENDFOR;

    // Drop the extra binary digits based on the number of = characters
    IF NumChars < InputLen;
        %LEN(OutputBinary) -= (InputLen-NumChars)*2;
    ENDIF;

    FOR i = 1 TO %LEN(OutputBinary) BY 8;
        AsciiNum = ToDecimal(%SUBST(OutputBinary:i:8));
        Output1 += AsciiChar;
        OutputLen += 1;
    ENDFOR;

    AsciiString  = Output1;
    AsciiLen     = OutputLen;
    EbcdicString = '';
    EbcdicLen    = MAX_LENGTH;

    iconv_from.ccsid = 819;
    iconv_to.ccsid = 37;
    iconv_table = iconv_open(iconv_to:iconv_from);
    iconv(iconv_table:AsciiPtr:AsciiLen:EbcdicPtr:EbcdicLen);
    iconv_close(iconv_table);

    Output = EbcdicString;

    RETURN;

END-PROC;



//------------------------------------------------------------------------------
// Procedure
//     ToBinary
//
// Description
//     Convert a decimal number to a binary bit string
//
// Parameters
//     Decimal - The decimal value to be converted to bits
//               (0 to 255)
//
// Return Value
//     String of bits that represent input value
//
//------------------------------------------------------------------------------
DCL-PROC ToBinary;
    DCL-PI *N CHAR(8);
        Decimal UNS(3) VALUE;
    END-PI;

    DCL-S BinaryArray ZONED(1:0) DIM(8);
    DCL-S Binary1     VARCHAR(8);
    DCL-S Binary      CHAR(8);
    DCL-S i           UNS(5);


    DOW Decimal > 0;
        i += 1;
        BinaryArray(i) = %REM(Decimal:2);
        Decimal /= 2;
    ENDDO;

    FOR i = 8 DOWNTO 1;
        Binary1 += %EDITC(BinaryArray(i):'X');
    ENDFOR;

    Binary = Binary1;

    RETURN Binary;

END-PROC;



//------------------------------------------------------------------------------
// Procedure
//     ToDecimal
//
// Description
//     Convert a binary bit string to a decimal number 
//
// Parameters
//     BinaryString - The decimal value to be converted to bits
//
// Return Value
//     Decimal value of input string
//
//------------------------------------------------------------------------------
DCL-PROC ToDecimal;
    DCL-PI *N UNS(3);
        BinaryString CHAR(8) VALUE;
    END-PI;

    DCL-S Base    UNS(5) INZ(1);
    DCL-S Binary  ZONED(8:0);
    DCL-S Decimal UNS(3);
    DCL-S Digit   ZONED(8:0);


    Binary = %DEC(BinaryString:8:0);
    DOW Binary > 0;
        Digit = %REM(Binary:10);
        Decimal += Digit * Base;
        Binary /= 10;
        Base *= 2;
    ENDDO;

    RETURN Decimal;

END-PROC;
