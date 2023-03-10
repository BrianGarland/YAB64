NAME=Yet Another Base64 encoder/decoder
BIN_LIB=YAB64
DBGVIEW=*SOURCE
TGTRLS=V7R4M0

#----------

all: yab64.rpgle
	@echo "Built all"

#----------

yab64.rpgle:
	-system -qi "CRTLIB LIB($(BIN_LIB)) TEXT('$(NAME)')"
	system "CRTRPGMOD MODULE($(BIN_LIB)/YAB64) SRCSTMF('QSOURCE/yab64.rpgle') TEXT('$(NAME)') REPLACE(*YES) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS)) INCDIR('QSOURCE')"
	system "CRTSRVPGM SRVPGM($(BIN_LIB)/YAB64) MODULE($(BIN_LIB)/YAB64) EXPORT(*ALL) TEXT('$(NAME)') REPLACE(*YES) ACTGRP(YAB64)"
	system "DLTOBJ OBJ($(BIN_LIB)/YAB64) OBJTYPE(*MODULE)"
	system "CRTBNDDIR BNDDIR($(BIN_LIB)/YAB64) TEXT('$(NAME)')"
	system "ADDBNDDIRE BNDDIR($(BIN_LIB)/YAB64) OBJ(($(BIN_LIB)/YAB64 *SRVPGM))"
	system "CRTBNDRPG PGM($(BIN_LIB)/YAB64TEST) SRCSTMF('QSOURCE/yab64test.rpgle') TEXT('YAB64 test program') REPLACE(*YES) DBGVIEW($(DBGVIEW)) TGTRLS($(TGTRLS)) INCDIR('QSOURCE')"
	
clean:
	system "CLRLIB $(BIN_LIB)"