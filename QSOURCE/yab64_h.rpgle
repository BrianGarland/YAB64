**FREE 

DCL-S MAX_LENGTH INT(10) INZ(32767);
DCL-S YAB64_Long_String CHAR(MAX_LENGTH);


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
DCL-PR YAB64_Encode;
    Input     LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
    InputLen  UNS(5) CONST;
    Output    LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
    OutputLen UNS(5);
    URLEncode IND OPTIONS(*NOPASS);
END-PR;



//------------------------------------------------------------------------------
// Procedure
//     YAB64_Decode
//
// Description
//     Base64 decode a character string
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
DCL-PR YAB64_Decode;
    Input     LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
    InputLen  UNS(5) CONST;
    Output    LIKE(YAB64_Long_String) OPTIONS(*VARSIZE);
    OutputLen UNS(5);
    URLEncode IND OPTIONS(*NOPASS);
END-PR;
