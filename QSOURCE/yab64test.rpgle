**FREE



CTL-OPT DFTACTGRP(*NO) ACTGRP('YAB64') BNDDIR('YAB64/YAB64');

/INCLUDE yab64_h.rpgle

DCL-DS StringDS;
    string1    LIKE(YAB64_Long_String) INZ;
    string1len UNS(5) INZ;
    string2    LIKE(YAB64_Long_String) INZ;
    string2len UNS(5) INZ;
    string3    LIKE(YAB64_Long_String) INZ;
    string3len UNS(5) INZ;
END-DS;



RESET StringDS;
string1 = 'Many hands make light work.';
string1len = %LEN(%TRIMR(string1));

yab64_encode(string1:string1len:string2:string2len);
yab64_decode(string2:string2len:string3:string3len);

IF string1 <> string3;
    DSPLY 'ERROR';
ENDIF;


RESET StringDS;
string1 = x'0001053489D367f4e2c7b2a58876236790FF';
string1len = %LEN(%TRIMR(string1));

yab64_encode(string1:string1len:string2:string2len);
yab64_decode(string2:string2len:string3:string3len);
IF string1 <> string3;
    DSPLY 'ERROR';
ENDIF;



*INLR = *ON;
RETURN;
