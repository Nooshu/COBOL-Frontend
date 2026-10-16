01 SERVER-CONTEXT.
   05 HTTP-REQUEST.
      10 REQ-METHOD           PIC X(8).
      10 REQ-PATH             PIC X(1024).
      10 REQ-PATH-LEN         PIC S9(9) COMP-5.
      10 REQ-RAW              PIC X(8192).
      10 REQ-RAW-LEN          PIC S9(9) COMP-5.
      10 REQ-STATUS           PIC 999.
      10 REQ-HEAD-ONLY        PIC X.
      10 REQ-QUERY            PIC X(128).
      10 REQ-QUERY-LEN        PIC S9(9) COMP-5.
      10 REQ-BODY             PIC X(4096).
      10 REQ-BODY-LEN         PIC S9(9) COMP-5.
   05 HTTP-RESPONSE.
      10 RES-STATUS           PIC 999.
      10 RES-CONTENT-TYPE     PIC X(80).
      10 RES-HAS-FILE         PIC X.
      10 RES-HAS-BODY         PIC X.
      10 RES-HEAD-ONLY        PIC X.
      10 RES-NO-STORE         PIC X.
      10 RES-SET-COOKIE       PIC X.
      10 RES-SESSION          PIC X(16).
      10 RES-LOCATION         PIC X(64).
      10 RES-FILE-PATH        PIC X(4096).
      10 RES-FILE-PATH-LEN    PIC S9(9) COMP-5.
      10 RES-BODY-LEN         PIC S9(9) COMP-5.
      10 RES-BODY             PIC X(32768).
   05 CANON-ROOT              PIC X(4096).
   05 CANON-ROOT-LEN          PIC S9(9) COMP-5.
