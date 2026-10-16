IDENTIFICATION DIVISION.
PROGRAM-ID. JOURNEY.

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
REPOSITORY.
    FUNCTION ALL INTRINSIC.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 STEP-ID                     PIC 99 VALUE 0.
01 FIRST-STEP                  PIC 99 VALUE 0.
01 NEXT-STEP                   PIC 99 VALUE 0.
01 SLOT                        PIC S9(4) COMP-5 VALUE 0.
01 SESSION-COUNT               PIC S9(4) COMP-5 VALUE 16.
01 REF-COUNTER                 PIC 9(6) VALUE 0.
01 SESSIONS OCCURS 16.
   05 SESS-ID                  PIC X(16).
   05 SESS-USED                PIC X.
   05 SESS-LICENCE             PIC X(16).
   05 SESS-NAME                PIC X(100).
   05 SESS-NAME-LEN            PIC S9(4) COMP-5.
   05 SESS-DAY                 PIC X(2).
   05 SESS-MONTH               PIC X(2).
   05 SESS-YEAR                PIC X(4).
   05 SESS-COUNTRY             PIC X(16).
   05 SESS-EMAIL               PIC X(100).
   05 SESS-EMAIL-LEN           PIC S9(4) COMP-5.
   05 SESS-REFERENCE           PIC X(10).
   05 SESS-SUBMITTED           PIC X.
   05 SESS-DONE                PIC X(5).
01 COOKIE-ID                   PIC X(16) VALUE SPACES.
01 HAS-COOKIE                  PIC X VALUE "N".
01 RETURN-CHECK                PIC X VALUE "N".
01 PAGE-LANG                   PIC X(2) VALUE "en".
01 PAGE-TITLE                  PIC X(160) VALUE SPACES.
01 PAGE-TITLE-LEN              PIC S9(4) COMP-5 VALUE 0.
01 ERROR-TEXT                  PIC X(120) VALUE SPACES.
01 ERROR-LEN                   PIC S9(4) COMP-5 VALUE 0.
01 BODY-PTR                    PIC S9(9) COMP-5 VALUE 1.
01 PARTIAL-NAME                PIC X(32) VALUE SPACES.
01 PARTIAL-LEN                 PIC S9(4) COMP-5 VALUE 0.
01 FILE-PATH                   PIC X(4097).
01 FILE-FD                     PIC S9(9) COMP-5 VALUE -1.
01 IO-BUF                      PIC X(1024).
01 CHUNK-SIZE                  PIC S9(9) COMP-5 VALUE 1024.
01 READ-COUNT                  PIC S9(9) COMP-5 VALUE 0.
01 RAND-BUF                    PIC X(8).
01 RAND-LEN                    PIC S9(9) COMP-5 VALUE 8.
01 RAND-GOT                    PIC S9(9) COMP-5 VALUE 0.
01 HEX-DIGITS                  PIC X(16) VALUE "0123456789abcdef".
01 BYTE-VAL                    PIC S9(4) COMP-5 VALUE 0.
01 HEX-INDEX                   PIC S9(4) COMP-5 VALUE 0.
01 POS                         PIC S9(9) COMP-5 VALUE 0.
01 PAIR-END                    PIC S9(9) COMP-5 VALUE 0.
01 EQUAL-AT                    PIC S9(9) COMP-5 VALUE 0.
01 NAME-BUF                    PIC X(40) VALUE SPACES.
01 NAME-LEN                    PIC S9(4) COMP-5 VALUE 0.
01 VALUE-BUF                   PIC X(200) VALUE SPACES.
01 VALUE-LEN                   PIC S9(4) COMP-5 VALUE 0.
01 DECODED                     PIC X(200) VALUE SPACES.
01 DECODED-LEN                 PIC S9(4) COMP-5 VALUE 0.
01 SRC-TEXT                    PIC X(200) VALUE SPACES.
01 SRC-LEN                     PIC S9(4) COMP-5 VALUE 0.
01 HEX-CHAR                    PIC X VALUE SPACE.
01 HIGH-NIBBLE                 PIC S9(4) COMP-5 VALUE -1.
01 LOW-NIBBLE                  PIC S9(4) COMP-5 VALUE -1.
01 HEX-VALUE                   PIC S9(4) COMP-5 VALUE 0.
01 FORM-LICENCE                PIC X(16) VALUE SPACES.
01 FORM-NAME                   PIC X(100) VALUE SPACES.
01 FORM-NAME-LEN               PIC S9(4) COMP-5 VALUE 0.
01 FORM-NAME-LONG              PIC X VALUE "N".
01 FORM-DAY                    PIC X(8) VALUE SPACES.
01 FORM-MONTH                  PIC X(8) VALUE SPACES.
01 FORM-YEAR                   PIC X(8) VALUE SPACES.
01 FORM-COUNTRY                PIC X(16) VALUE SPACES.
01 FORM-EMAIL                  PIC X(100) VALUE SPACES.
01 FORM-EMAIL-LEN              PIC S9(4) COMP-5 VALUE 0.
01 FORM-EMAIL-LONG             PIC X VALUE "N".
01 FORM-RETURN                 PIC X VALUE "N".
01 DAY-TEXT                    PIC X(8) VALUE SPACES.
01 MONTH-TEXT                  PIC X(8) VALUE SPACES.
01 YEAR-TEXT                   PIC X(8) VALUE SPACES.
01 DAY-NUM                     PIC 99 VALUE 0.
01 MONTH-NUM                   PIC 99 VALUE 0.
01 YEAR-NUM                    PIC 9999 VALUE 0.
01 TODAY-NUM                   PIC 9(8) VALUE 0.
01 TODAY-YEAR                  PIC 9999 VALUE 0.
01 TODAY-MONTH                 PIC 99 VALUE 0.
01 TODAY-DAY                   PIC 99 VALUE 0.
01 AGE                         PIC S9(4) COMP-5 VALUE 0.
01 MAX-DAY                     PIC 99 VALUE 0.
01 LEAP                        PIC X VALUE "N".
01 YEAR-MOD-4                  PIC 99 VALUE 0.
01 YEAR-MOD-100                PIC 999 VALUE 0.
01 YEAR-MOD-400                PIC 999 VALUE 0.
01 AT-POS                      PIC S9(4) COMP-5 VALUE 0.
01 DOT-POS                     PIC S9(4) COMP-5 VALUE 0.
01 SCAN                        PIC S9(4) COMP-5 VALUE 0.
01 CHECKED                     PIC X VALUE "N".
01 REF-TEXT                    PIC 9(6) VALUE 0.
01 LABEL-TEXT                  PIC X(16) VALUE SPACES.

LINKAGE SECTION.
COPY "http.cpy".

PROCEDURE DIVISION USING SERVER-CONTEXT.
DISPATCH.
    MOVE 0 TO RES-STATUS
    PERFORM CLASSIFY-PATH
    IF STEP-ID = 9
        IF REQ-METHOD = "POST"
            MOVE 405 TO RES-STATUS
        END-IF
        EXIT PROGRAM
    END-IF
    IF REQ-METHOD NOT = "GET" AND REQ-METHOD NOT = "POST"
        AND REQ-METHOD NOT = "HEAD"
        MOVE 405 TO RES-STATUS
        EXIT PROGRAM
    END-IF
    MOVE "N" TO RETURN-CHECK
    IF REQ-QUERY-LEN >= 20
        AND REQ-QUERY(1:20) = "return=check-answers"
        MOVE "Y" TO RETURN-CHECK
    END-IF
    PERFORM ENSURE-SESSION
    IF REQ-METHOD = "POST"
        PERFORM CLEAR-FORM
        PERFORM PARSE-FORM
        IF FORM-RETURN = "Y"
            MOVE "Y" TO RETURN-CHECK
        END-IF
        PERFORM HANDLE-POST
    ELSE
        PERFORM LOAD-FORM
        PERFORM HANDLE-GET
    END-IF
    EXIT PROGRAM.

CLASSIFY-PATH.
    EVALUATE TRUE
        WHEN REQ-PATH-LEN = 1 AND REQ-PATH(1:1) = "/"
            MOVE 0 TO STEP-ID
        WHEN REQ-PATH-LEN = 3 AND REQ-PATH(1:3) = "/cy"
            MOVE 1 TO STEP-ID
        WHEN REQ-PATH-LEN = 15 AND REQ-PATH(1:15) = "/licence-length"
            MOVE 2 TO STEP-ID
        WHEN REQ-PATH-LEN = 5 AND REQ-PATH(1:5) = "/name"
            MOVE 3 TO STEP-ID
        WHEN REQ-PATH-LEN = 14 AND REQ-PATH(1:14) = "/date-of-birth"
            MOVE 4 TO STEP-ID
        WHEN REQ-PATH-LEN = 20
            AND REQ-PATH(1:20) = "/where-you-will-fish"
            MOVE 5 TO STEP-ID
        WHEN REQ-PATH-LEN = 6 AND REQ-PATH(1:6) = "/email"
            MOVE 6 TO STEP-ID
        WHEN REQ-PATH-LEN = 14 AND REQ-PATH(1:14) = "/check-answers"
            MOVE 7 TO STEP-ID
        WHEN REQ-PATH-LEN = 13 AND REQ-PATH(1:13) = "/confirmation"
            MOVE 8 TO STEP-ID
        WHEN OTHER
            MOVE 9 TO STEP-ID
    END-EVALUATE.

ENSURE-SESSION.
    MOVE "N" TO HAS-COOKIE
    MOVE SPACES TO COOKIE-ID
    PERFORM FIND-COOKIE
    MOVE 0 TO SLOT
    IF HAS-COOKIE = "Y"
        PERFORM VARYING SLOT FROM 1 BY 1
            UNTIL SLOT > SESSION-COUNT
            OR SESS-ID(SLOT) = COOKIE-ID
            CONTINUE
        END-PERFORM
        IF SLOT > SESSION-COUNT OR SESS-USED(SLOT) NOT = "Y"
            MOVE 0 TO SLOT
        END-IF
    END-IF
    IF SLOT = 0
        PERFORM VARYING SLOT FROM 1 BY 1
            UNTIL SLOT > SESSION-COUNT OR SESS-USED(SLOT) NOT = "Y"
            CONTINUE
        END-PERFORM
        IF SLOT > SESSION-COUNT
            MOVE 1 TO SLOT
        END-IF
        MOVE SPACES TO SESS-ID(SLOT)
        MOVE SPACES TO SESS-LICENCE(SLOT)
        MOVE SPACES TO SESS-NAME(SLOT)
        MOVE 0 TO SESS-NAME-LEN(SLOT)
        MOVE SPACES TO SESS-DAY(SLOT)
        MOVE SPACES TO SESS-MONTH(SLOT)
        MOVE SPACES TO SESS-YEAR(SLOT)
        MOVE SPACES TO SESS-COUNTRY(SLOT)
        MOVE SPACES TO SESS-EMAIL(SLOT)
        MOVE 0 TO SESS-EMAIL-LEN(SLOT)
        MOVE SPACES TO SESS-REFERENCE(SLOT)
        MOVE "N" TO SESS-SUBMITTED(SLOT)
        MOVE "NNNNN" TO SESS-DONE(SLOT)
        PERFORM MAKE-SESSION-ID
        MOVE "Y" TO SESS-USED(SLOT)
    END-IF
    MOVE "Y" TO RES-SET-COOKIE
    MOVE SESS-ID(SLOT) TO RES-SESSION.

FIND-COOKIE.
    IF REQ-RAW-LEN < 24
        EXIT PARAGRAPH
    END-IF
    PERFORM VARYING POS FROM 1 BY 1
        UNTIL POS > REQ-RAW-LEN - 23 OR HAS-COOKIE = "Y"
        IF REQ-RAW(POS:8) = "session="
            IF REQ-RAW(POS + 8:16) IS NOT = SPACES
                MOVE REQ-RAW(POS + 8:16) TO COOKIE-ID
                MOVE "Y" TO HAS-COOKIE
                PERFORM VARYING SCAN FROM 1 BY 1 UNTIL SCAN > 16
                    IF COOKIE-ID(SCAN:1) < "0"
                        OR (COOKIE-ID(SCAN:1) > "9"
                            AND COOKIE-ID(SCAN:1) < "a")
                        OR COOKIE-ID(SCAN:1) > "f"
                        MOVE "N" TO HAS-COOKIE
                    END-IF
                END-PERFORM
            END-IF
        END-IF
    END-PERFORM.

MAKE-SESSION-ID.
    CALL "GWS_RANDOM" USING
        BY REFERENCE RAND-BUF
        BY VALUE RAND-LEN
        RETURNING RAND-GOT
    IF RAND-GOT NOT = 8
        MOVE "0000000000000000" TO SESS-ID(SLOT)
        EXIT PARAGRAPH
    END-IF
    PERFORM VARYING SCAN FROM 1 BY 1 UNTIL SCAN > 8
        COMPUTE BYTE-VAL = ORD(RAND-BUF(SCAN:1)) - 1
        IF BYTE-VAL < 0
            MOVE 0 TO BYTE-VAL
        END-IF
        COMPUTE HEX-INDEX = BYTE-VAL / 16 + 1
        MOVE HEX-DIGITS(HEX-INDEX:1)
            TO SESS-ID(SLOT)(SCAN * 2 - 1:1)
        COMPUTE HEX-INDEX = FUNCTION MOD(BYTE-VAL, 16) + 1
        MOVE HEX-DIGITS(HEX-INDEX:1)
            TO SESS-ID(SLOT)(SCAN * 2:1)
    END-PERFORM.

CLEAR-FORM.
    MOVE SPACES TO FORM-LICENCE
    MOVE SPACES TO FORM-NAME
    MOVE 0 TO FORM-NAME-LEN
    MOVE "N" TO FORM-NAME-LONG
    MOVE SPACES TO FORM-DAY
    MOVE SPACES TO FORM-MONTH
    MOVE SPACES TO FORM-YEAR
    MOVE SPACES TO FORM-COUNTRY
    MOVE SPACES TO FORM-EMAIL
    MOVE 0 TO FORM-EMAIL-LEN
    MOVE "N" TO FORM-EMAIL-LONG
    MOVE "N" TO FORM-RETURN.

LOAD-FORM.
    MOVE SESS-LICENCE(SLOT) TO FORM-LICENCE
    MOVE SESS-NAME(SLOT) TO FORM-NAME
    MOVE SESS-NAME-LEN(SLOT) TO FORM-NAME-LEN
    MOVE SESS-DAY(SLOT) TO FORM-DAY
    MOVE SESS-MONTH(SLOT) TO FORM-MONTH
    MOVE SESS-YEAR(SLOT) TO FORM-YEAR
    MOVE SESS-COUNTRY(SLOT) TO FORM-COUNTRY
    MOVE SESS-EMAIL(SLOT) TO FORM-EMAIL
    MOVE SESS-EMAIL-LEN(SLOT) TO FORM-EMAIL-LEN.

PARSE-FORM.
    MOVE "N" TO FORM-RETURN
    MOVE 1 TO POS
    PERFORM UNTIL POS > REQ-BODY-LEN
        MOVE POS TO PAIR-END
        PERFORM UNTIL PAIR-END > REQ-BODY-LEN
            OR REQ-BODY(PAIR-END:1) = "&"
            ADD 1 TO PAIR-END
        END-PERFORM
        MOVE 0 TO EQUAL-AT
        PERFORM VARYING SCAN FROM POS BY 1 UNTIL SCAN >= PAIR-END
            IF REQ-BODY(SCAN:1) = "=" AND EQUAL-AT = 0
                MOVE SCAN TO EQUAL-AT
            END-IF
        END-PERFORM
        IF EQUAL-AT > POS
            COMPUTE SRC-LEN = EQUAL-AT - POS
            MOVE REQ-BODY(POS:SRC-LEN) TO SRC-TEXT
            PERFORM DECODE-VALUE
            MOVE DECODED TO NAME-BUF
            MOVE DECODED-LEN TO NAME-LEN
            COMPUTE SRC-LEN = PAIR-END - EQUAL-AT - 1
            IF SRC-LEN > 0
                MOVE REQ-BODY(EQUAL-AT + 1:SRC-LEN) TO SRC-TEXT
                PERFORM DECODE-VALUE
            ELSE
                MOVE 0 TO DECODED-LEN
                MOVE SPACES TO DECODED
            END-IF
            MOVE DECODED TO VALUE-BUF
            MOVE DECODED-LEN TO VALUE-LEN
            PERFORM STORE-FIELD
        END-IF
        IF PAIR-END <= REQ-BODY-LEN
            AND REQ-BODY(PAIR-END:1) = "&"
            COMPUTE POS = PAIR-END + 1
        ELSE
            COMPUTE POS = PAIR-END
        END-IF
    END-PERFORM.

STORE-FIELD.
    EVALUATE TRUE
        WHEN NAME-LEN = 14 AND NAME-BUF(1:14) = "licence-length"
            IF VALUE-LEN > 16
                MOVE 16 TO VALUE-LEN
            END-IF
            MOVE SPACES TO FORM-LICENCE
            IF VALUE-LEN > 0
                MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-LICENCE
            END-IF
        WHEN NAME-LEN = 9 AND NAME-BUF(1:9) = "full-name"
            IF VALUE-LEN > 100
                MOVE "Y" TO FORM-NAME-LONG
                MOVE 100 TO VALUE-LEN
            END-IF
            MOVE SPACES TO FORM-NAME
            MOVE VALUE-LEN TO FORM-NAME-LEN
            IF VALUE-LEN > 0
                MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-NAME
            END-IF
        WHEN NAME-LEN = 17 AND NAME-BUF(1:17) = "date-of-birth-day"
            PERFORM STORE-DAY
        WHEN NAME-LEN = 19 AND NAME-BUF(1:19) = "date-of-birth-month"
            PERFORM STORE-MONTH
        WHEN NAME-LEN = 18 AND NAME-BUF(1:18) = "date-of-birth-year"
            PERFORM STORE-YEAR
        WHEN NAME-LEN = 7 AND NAME-BUF(1:7) = "country"
            IF VALUE-LEN > 16
                MOVE 16 TO VALUE-LEN
            END-IF
            MOVE SPACES TO FORM-COUNTRY
            IF VALUE-LEN > 0
                MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-COUNTRY
            END-IF
        WHEN NAME-LEN = 5 AND NAME-BUF(1:5) = "email"
            IF VALUE-LEN > 100
                MOVE "Y" TO FORM-EMAIL-LONG
                MOVE 100 TO VALUE-LEN
            END-IF
            MOVE SPACES TO FORM-EMAIL
            MOVE VALUE-LEN TO FORM-EMAIL-LEN
            IF VALUE-LEN > 0
                MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-EMAIL
            END-IF
        WHEN NAME-LEN = 6 AND NAME-BUF(1:6) = "return"
            IF VALUE-LEN = 13 AND VALUE-BUF(1:13) = "check-answers"
                MOVE "Y" TO FORM-RETURN
            END-IF
    END-EVALUATE.

STORE-DAY.
    IF VALUE-LEN > 8
        MOVE 8 TO VALUE-LEN
    END-IF
    MOVE SPACES TO FORM-DAY
    IF VALUE-LEN > 0
        MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-DAY
    END-IF.

STORE-MONTH.
    IF VALUE-LEN > 8
        MOVE 8 TO VALUE-LEN
    END-IF
    MOVE SPACES TO FORM-MONTH
    IF VALUE-LEN > 0
        MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-MONTH
    END-IF.

STORE-YEAR.
    IF VALUE-LEN > 8
        MOVE 8 TO VALUE-LEN
    END-IF
    MOVE SPACES TO FORM-YEAR
    IF VALUE-LEN > 0
        MOVE VALUE-BUF(1:VALUE-LEN) TO FORM-YEAR
    END-IF.

DECODE-VALUE.
    MOVE SPACES TO DECODED
    MOVE 0 TO DECODED-LEN
    MOVE 1 TO SCAN
    PERFORM UNTIL SCAN > SRC-LEN OR DECODED-LEN >= 200
        EVALUATE SRC-TEXT(SCAN:1)
            WHEN "+"
                ADD 1 TO DECODED-LEN
                MOVE SPACE TO DECODED(DECODED-LEN:1)
                ADD 1 TO SCAN
            WHEN "%"
                IF SCAN + 2 > SRC-LEN
                    ADD 1 TO DECODED-LEN
                    MOVE "%" TO DECODED(DECODED-LEN:1)
                    ADD 1 TO SCAN
                ELSE
                    MOVE SRC-TEXT(SCAN + 1:1) TO HEX-CHAR
                    PERFORM HEX-NIBBLE
                    MOVE LOW-NIBBLE TO HIGH-NIBBLE
                    MOVE SRC-TEXT(SCAN + 2:1) TO HEX-CHAR
                    PERFORM HEX-NIBBLE
                    IF HIGH-NIBBLE < 0 OR LOW-NIBBLE < 0
                        ADD 1 TO DECODED-LEN
                        MOVE "%" TO DECODED(DECODED-LEN:1)
                        ADD 1 TO SCAN
                    ELSE
                        COMPUTE HEX-VALUE = HIGH-NIBBLE * 16 + LOW-NIBBLE
                        ADD 1 TO DECODED-LEN
                        MOVE FUNCTION CHAR(HEX-VALUE + 1)
                            TO DECODED(DECODED-LEN:1)
                        ADD 3 TO SCAN
                    END-IF
                END-IF
            WHEN OTHER
                ADD 1 TO DECODED-LEN
                MOVE SRC-TEXT(SCAN:1) TO DECODED(DECODED-LEN:1)
                ADD 1 TO SCAN
        END-EVALUATE
    END-PERFORM.

HEX-NIBBLE.
    MOVE UPPER-CASE(HEX-CHAR) TO HEX-CHAR
    MOVE -1 TO LOW-NIBBLE
    IF HEX-CHAR >= "0" AND HEX-CHAR <= "9"
        COMPUTE LOW-NIBBLE = ORD(HEX-CHAR) - ORD("0")
    END-IF
    IF HEX-CHAR >= "A" AND HEX-CHAR <= "F"
        COMPUTE LOW-NIBBLE = ORD(HEX-CHAR) - ORD("A") + 10
    END-IF.

HANDLE-GET.
    EVALUATE STEP-ID
        WHEN 0
            PERFORM RENDER-START
        WHEN 1
            PERFORM RENDER-START
        WHEN 2 THRU 6
            PERFORM GUARD-QUESTION
            IF RES-STATUS = 0
                PERFORM RENDER-QUESTION
            END-IF
        WHEN 7
            IF SESS-SUBMITTED(SLOT) = "Y"
                PERFORM REDIRECT-CONFIRMATION
            ELSE
                PERFORM FIND-FIRST
                IF FIRST-STEP NOT = 0
                    PERFORM REDIRECT-FIRST
                ELSE
                    PERFORM RENDER-CHECK
                END-IF
            END-IF
        WHEN 8
            IF SESS-SUBMITTED(SLOT) NOT = "Y"
                MOVE "/" TO RES-LOCATION
                PERFORM REDIRECT
            ELSE
                PERFORM RENDER-CONFIRMATION
            END-IF
    END-EVALUATE.

HANDLE-POST.
    EVALUATE STEP-ID
        WHEN 0
        WHEN 1
            PERFORM RENDER-START
        WHEN 2
            PERFORM VALIDATE-LICENCE
            IF ERROR-LEN = 0
                MOVE FORM-LICENCE TO SESS-LICENCE(SLOT)
                MOVE "Y" TO SESS-DONE(SLOT)(1:1)
                MOVE 3 TO NEXT-STEP
                PERFORM AFTER-SAVE
            ELSE
                PERFORM RENDER-QUESTION
            END-IF
        WHEN 3
            PERFORM GUARD-QUESTION
            IF RES-STATUS = 0
                PERFORM VALIDATE-NAME
                IF ERROR-LEN = 0
                    MOVE FORM-NAME TO SESS-NAME(SLOT)
                    MOVE FORM-NAME-LEN TO SESS-NAME-LEN(SLOT)
                    MOVE "Y" TO SESS-DONE(SLOT)(2:1)
                    MOVE 4 TO NEXT-STEP
                    PERFORM AFTER-SAVE
                ELSE
                    PERFORM RENDER-QUESTION
                END-IF
            END-IF
        WHEN 4
            PERFORM GUARD-QUESTION
            IF RES-STATUS = 0
                PERFORM VALIDATE-DATE
                IF ERROR-LEN = 0
                    MOVE DAY-TEXT TO SESS-DAY(SLOT)
                    MOVE MONTH-TEXT TO SESS-MONTH(SLOT)
                    MOVE YEAR-TEXT TO SESS-YEAR(SLOT)
                    MOVE "Y" TO SESS-DONE(SLOT)(3:1)
                    MOVE 5 TO NEXT-STEP
                    PERFORM AFTER-SAVE
                ELSE
                    PERFORM RENDER-QUESTION
                END-IF
            END-IF
        WHEN 5
            PERFORM GUARD-QUESTION
            IF RES-STATUS = 0
                PERFORM VALIDATE-COUNTRY
                IF ERROR-LEN = 0
                    MOVE FORM-COUNTRY TO SESS-COUNTRY(SLOT)
                    MOVE "Y" TO SESS-DONE(SLOT)(4:1)
                    MOVE 6 TO NEXT-STEP
                    PERFORM AFTER-SAVE
                ELSE
                    PERFORM RENDER-QUESTION
                END-IF
            END-IF
        WHEN 6
            PERFORM GUARD-QUESTION
            IF RES-STATUS = 0
                PERFORM VALIDATE-EMAIL
                IF ERROR-LEN = 0
                    MOVE FORM-EMAIL TO SESS-EMAIL(SLOT)
                    MOVE FORM-EMAIL-LEN TO SESS-EMAIL-LEN(SLOT)
                    MOVE "Y" TO SESS-DONE(SLOT)(5:1)
                    MOVE 7 TO NEXT-STEP
                    PERFORM AFTER-SAVE
                ELSE
                    PERFORM RENDER-QUESTION
                END-IF
            END-IF
        WHEN 7
            PERFORM FIND-FIRST
            IF FIRST-STEP NOT = 0
                PERFORM REDIRECT-FIRST
            ELSE
                PERFORM ISSUE-REFERENCE
                MOVE "Y" TO SESS-SUBMITTED(SLOT)
                PERFORM REDIRECT-CONFIRMATION
            END-IF
        WHEN 8
            PERFORM HANDLE-GET
    END-EVALUATE.

GUARD-QUESTION.
    PERFORM FIND-FIRST
    IF FIRST-STEP NOT = 0 AND FIRST-STEP < STEP-ID
        PERFORM REDIRECT-FIRST
    END-IF.

AFTER-SAVE.
    PERFORM FIND-FIRST
    IF RETURN-CHECK = "Y" AND FIRST-STEP = 0
        MOVE 7 TO NEXT-STEP
    END-IF
    IF FIRST-STEP NOT = 0 AND FIRST-STEP < NEXT-STEP
        MOVE FIRST-STEP TO NEXT-STEP
    END-IF
    PERFORM REDIRECT-STEP.

FIND-FIRST.
    IF SESS-DONE(SLOT)(1:1) NOT = "Y"
        MOVE 2 TO FIRST-STEP
    ELSE
        IF SESS-DONE(SLOT)(2:1) NOT = "Y"
            MOVE 3 TO FIRST-STEP
        ELSE
            IF SESS-DONE(SLOT)(3:1) NOT = "Y"
                MOVE 4 TO FIRST-STEP
            ELSE
                IF SESS-DONE(SLOT)(4:1) NOT = "Y"
                    MOVE 5 TO FIRST-STEP
                ELSE
                    IF SESS-DONE(SLOT)(5:1) NOT = "Y"
                        MOVE 6 TO FIRST-STEP
                    ELSE
                        MOVE 0 TO FIRST-STEP
                    END-IF
                END-IF
            END-IF
        END-IF
    END-IF.

REDIRECT-FIRST.
    MOVE FIRST-STEP TO NEXT-STEP
    PERFORM REDIRECT-STEP.

REDIRECT-CONFIRMATION.
    MOVE "/confirmation" TO RES-LOCATION
    PERFORM REDIRECT.

REDIRECT-STEP.
    EVALUATE NEXT-STEP
        WHEN 2
            MOVE "/licence-length" TO RES-LOCATION
        WHEN 3
            MOVE "/name" TO RES-LOCATION
        WHEN 4
            MOVE "/date-of-birth" TO RES-LOCATION
        WHEN 5
            MOVE "/where-you-will-fish" TO RES-LOCATION
        WHEN 6
            MOVE "/email" TO RES-LOCATION
        WHEN 7
            MOVE "/check-answers" TO RES-LOCATION
        WHEN OTHER
            MOVE "/confirmation" TO RES-LOCATION
    END-EVALUATE
    PERFORM REDIRECT.

REDIRECT.
    MOVE 303 TO RES-STATUS
    MOVE "N" TO RES-HAS-BODY
    MOVE "Y" TO RES-NO-STORE
    MOVE "text/html; charset=utf-8" TO RES-CONTENT-TYPE.

VALIDATE-LICENCE.
    MOVE 0 TO ERROR-LEN
    IF FORM-LICENCE = "1-day" OR FORM-LICENCE = "8-days"
        OR FORM-LICENCE = "12-months"
        CONTINUE
    ELSE
        MOVE "Select how long you need the licence for" TO ERROR-TEXT
        MOVE 40 TO ERROR-LEN
    END-IF.

VALIDATE-NAME.
    MOVE 0 TO ERROR-LEN
    IF FORM-NAME-LONG = "Y" OR LENGTH(TRIM(FORM-NAME)) > 100
        MOVE "Full name must be 100 characters or fewer" TO ERROR-TEXT
        MOVE 41 TO ERROR-LEN
    ELSE
        IF LENGTH(TRIM(FORM-NAME)) < 2
            MOVE "Enter your full name" TO ERROR-TEXT
            MOVE 20 TO ERROR-LEN
        ELSE
            MOVE TRIM(FORM-NAME) TO FORM-NAME
            COMPUTE FORM-NAME-LEN = LENGTH(TRIM(FORM-NAME))
        END-IF
    END-IF.

VALIDATE-COUNTRY.
    MOVE 0 TO ERROR-LEN
    IF FORM-COUNTRY = "England" OR FORM-COUNTRY = "Wales"
        OR FORM-COUNTRY = "Scotland"
        CONTINUE
    ELSE
        MOVE "Select where you will fish" TO ERROR-TEXT
        MOVE 26 TO ERROR-LEN
    END-IF.

VALIDATE-EMAIL.
    MOVE 0 TO ERROR-LEN
    IF FORM-EMAIL-LONG = "Y"
        MOVE "Enter an email address in the correct format, like name@example.com"
            TO ERROR-TEXT
        MOVE 67 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    MOVE TRIM(FORM-EMAIL) TO FORM-EMAIL
    COMPUTE FORM-EMAIL-LEN = LENGTH(TRIM(FORM-EMAIL))
    MOVE 0 TO AT-POS
    MOVE 0 TO DOT-POS
    PERFORM VARYING SCAN FROM 1 BY 1 UNTIL SCAN > FORM-EMAIL-LEN
        IF FORM-EMAIL(SCAN:1) = "@"
            IF AT-POS = 0
                MOVE SCAN TO AT-POS
            ELSE
                MOVE 0 TO AT-POS
                EXIT PERFORM
            END-IF
        END-IF
        IF FORM-EMAIL(SCAN:1) = SPACE
            MOVE 0 TO AT-POS
            EXIT PERFORM
        END-IF
    END-PERFORM
    IF AT-POS > 1 AND AT-POS < FORM-EMAIL-LEN
        PERFORM VARYING SCAN FROM AT-POS BY 1
            UNTIL SCAN > FORM-EMAIL-LEN
            IF FORM-EMAIL(SCAN:1) = "."
                MOVE SCAN TO DOT-POS
            END-IF
        END-PERFORM
    END-IF
    IF AT-POS < 2 OR DOT-POS <= AT-POS + 1
        OR DOT-POS >= FORM-EMAIL-LEN
        MOVE "Enter an email address in the correct format, like name@example.com"
            TO ERROR-TEXT
        MOVE 67 TO ERROR-LEN
    END-IF.

VALIDATE-DATE.
    MOVE 0 TO ERROR-LEN
    MOVE TRIM(FORM-DAY) TO DAY-TEXT
    MOVE TRIM(FORM-MONTH) TO MONTH-TEXT
    MOVE TRIM(FORM-YEAR) TO YEAR-TEXT
    IF DAY-TEXT = SPACES OR MONTH-TEXT = SPACES OR YEAR-TEXT = SPACES
        MOVE "Enter your date of birth" TO ERROR-TEXT
        MOVE 24 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    IF LENGTH(TRIM(DAY-TEXT)) > 2
        OR LENGTH(TRIM(MONTH-TEXT)) > 2
        OR LENGTH(TRIM(YEAR-TEXT)) NOT = 4
        MOVE "Enter a real date of birth" TO ERROR-TEXT
        MOVE 26 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    IF TEST-NUMVAL(TRIM(DAY-TEXT)) NOT = 0
        OR TEST-NUMVAL(TRIM(MONTH-TEXT)) NOT = 0
        OR TEST-NUMVAL(TRIM(YEAR-TEXT)) NOT = 0
        MOVE "Enter a real date of birth" TO ERROR-TEXT
        MOVE 26 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    COMPUTE DAY-NUM = NUMVAL(TRIM(DAY-TEXT))
    COMPUTE MONTH-NUM = NUMVAL(TRIM(MONTH-TEXT))
    COMPUTE YEAR-NUM = NUMVAL(TRIM(YEAR-TEXT))
    PERFORM DAYS-IN-MONTH
    IF MONTH-NUM < 1 OR MONTH-NUM > 12
        OR DAY-NUM < 1 OR DAY-NUM > MAX-DAY
        MOVE "Enter a real date of birth" TO ERROR-TEXT
        MOVE 26 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    ACCEPT TODAY-NUM FROM DATE YYYYMMDD
    COMPUTE TODAY-YEAR = TODAY-NUM / 10000
    COMPUTE TODAY-MONTH = FUNCTION MOD(TODAY-NUM, 10000) / 100
    COMPUTE TODAY-DAY = FUNCTION MOD(TODAY-NUM, 100)
    IF YEAR-NUM > TODAY-YEAR
        OR (YEAR-NUM = TODAY-YEAR AND MONTH-NUM > TODAY-MONTH)
        OR (YEAR-NUM = TODAY-YEAR AND MONTH-NUM = TODAY-MONTH
            AND DAY-NUM > TODAY-DAY)
        MOVE "Date of birth must be in the past" TO ERROR-TEXT
        MOVE 33 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    COMPUTE AGE = TODAY-YEAR - YEAR-NUM
    IF TODAY-MONTH < MONTH-NUM
        OR (TODAY-MONTH = MONTH-NUM AND TODAY-DAY < DAY-NUM)
        SUBTRACT 1 FROM AGE
    END-IF
    IF AGE < 13
        MOVE "You must be at least 13 to use this example" TO ERROR-TEXT
        MOVE 43 TO ERROR-LEN
        EXIT PARAGRAPH
    END-IF
    MOVE TRIM(DAY-TEXT) TO DAY-TEXT
    MOVE TRIM(MONTH-TEXT) TO MONTH-TEXT
    MOVE TRIM(YEAR-TEXT) TO YEAR-TEXT.

DAYS-IN-MONTH.
    EVALUATE MONTH-NUM
        WHEN 1 MOVE 31 TO MAX-DAY
        WHEN 2
            PERFORM LEAP-YEAR
            IF LEAP = "Y"
                MOVE 29 TO MAX-DAY
            ELSE
                MOVE 28 TO MAX-DAY
            END-IF
        WHEN 3 MOVE 31 TO MAX-DAY
        WHEN 4 MOVE 30 TO MAX-DAY
        WHEN 5 MOVE 31 TO MAX-DAY
        WHEN 6 MOVE 30 TO MAX-DAY
        WHEN 7 MOVE 31 TO MAX-DAY
        WHEN 8 MOVE 31 TO MAX-DAY
        WHEN 9 MOVE 30 TO MAX-DAY
        WHEN 10 MOVE 31 TO MAX-DAY
        WHEN 11 MOVE 30 TO MAX-DAY
        WHEN 12 MOVE 31 TO MAX-DAY
        WHEN OTHER MOVE 0 TO MAX-DAY
    END-EVALUATE.

LEAP-YEAR.
    DIVIDE YEAR-NUM BY 4 GIVING SCAN REMAINDER YEAR-MOD-4
    DIVIDE YEAR-NUM BY 100 GIVING SCAN REMAINDER YEAR-MOD-100
    DIVIDE YEAR-NUM BY 400 GIVING SCAN REMAINDER YEAR-MOD-400
    IF YEAR-MOD-4 = 0 AND (YEAR-MOD-100 NOT = 0 OR YEAR-MOD-400 = 0)
        MOVE "Y" TO LEAP
    ELSE
        MOVE "N" TO LEAP
    END-IF.

ISSUE-REFERENCE.
    IF SESS-REFERENCE(SLOT) NOT = SPACES
        EXIT PARAGRAPH
    END-IF
    ADD 1 TO REF-COUNTER
    MOVE REF-COUNTER TO REF-TEXT
    MOVE "FRL-000000" TO SESS-REFERENCE(SLOT)
    MOVE REF-TEXT(1:1) TO SESS-REFERENCE(SLOT)(5:1)
    MOVE REF-TEXT(2:1) TO SESS-REFERENCE(SLOT)(6:1)
    MOVE REF-TEXT(3:1) TO SESS-REFERENCE(SLOT)(7:1)
    MOVE REF-TEXT(4:1) TO SESS-REFERENCE(SLOT)(8:1)
    MOVE REF-TEXT(5:1) TO SESS-REFERENCE(SLOT)(9:1)
    MOVE REF-TEXT(6:1) TO SESS-REFERENCE(SLOT)(10:1).

RENDER-START.
    IF STEP-ID = 1
        MOVE "cy" TO PAGE-LANG
        MOVE "Gwneud cais am drwydded bysgota" TO PAGE-TITLE
        MOVE 31 TO PAGE-TITLE-LEN
    ELSE
        MOVE "en" TO PAGE-LANG
        MOVE "Apply for a fishing rod licence" TO PAGE-TITLE
        MOVE 31 TO PAGE-TITLE-LEN
    END-IF
    PERFORM BEGIN-PAGE
    IF STEP-ID = 1
        PERFORM START-WELSH
    ELSE
        PERFORM START-ENGLISH
    END-IF
    PERFORM END-PAGE.

START-ENGLISH.
    STRING
        "<div class=""govuk-grid-row""><div class=""govuk-grid-column-two-thirds"">"
        "<div class=""govuk-notification-banner"" role=""region"" "
        "aria-labelledby=""licence-available-title"" "
        "data-module=""govuk-notification-banner"">"
        "<div class=""govuk-notification-banner__header"">"
        "<h2 class=""govuk-notification-banner__title"" "
        "id=""licence-available-title"">Important</h2></div>"
        "<div class=""govuk-notification-banner__content"">"
        "<p class=""govuk-notification-banner__heading"">"
        "The 2026 to 2027 rod licence is now available.</p></div></div>"
        "<h1 class=""govuk-heading-xl"">Apply for a fishing rod licence</h1>"
        "<p class=""govuk-body-l"">Use this service to apply for a licence to fish with a rod.</p>"
        "<a href=""/licence-length"" role=""button"" draggable=""false"" "
        "class=""govuk-button govuk-button--start"" data-module=""govuk-button"">"
        "Start now"
        "<svg class=""govuk-button__start-icon"" xmlns=""http://www.w3.org/2000/svg"" "
        "width=""17.5"" height=""19"" viewBox=""0 0 33 40"" aria-hidden=""true"" "
        "focusable=""false""><path fill=""currentColor"" "
        "d=""M0 0h13l20 20-20 20H0l20-20z""/></svg></a>"
        "<p class=""govuk-body"">Applying takes about 10 minutes.</p>"
        "<div class=""govuk-warning-text"">"
        "<span class=""govuk-warning-text__icon"" aria-hidden=""true"">!</span>"
        "<strong class=""govuk-warning-text__text"">"
        "<span class=""govuk-visually-hidden"">Warning</span>"
        "You must have a valid rod licence before you fish."
        "</strong></div>"
        "<div class=""govuk-inset-text"">"
        "You need to be 13 or over. This example does not take payment."
        "</div>"
        "<details class=""govuk-details"">"
        "<summary class=""govuk-details__summary"">"
        "<span class=""govuk-details__summary-text"">What you will need</span>"
        "</summary><div class=""govuk-details__text"">"
        "<ul class=""govuk-list govuk-list--bullet"">"
        "<li>How long you need the licence</li><li>Your name</li>"
        "<li>Your date of birth</li><li>The country where you will fish</li>"
        "<li>Your email address</li></ul></div></details>"
        "<h2 class=""govuk-heading-m"">Developer previews</h2>"
        "<p class=""govuk-body"">Preview GOV.UK components, a separate page for each component. "
        "<a class=""govuk-link"" href=""/components"">Component catalogue</a>.</p>"
        "<p class=""govuk-body""><a class=""govuk-link"" href=""/cy"" hreflang=""cy"" "
        "lang=""cy"">Cymraeg</a></p>"
        "</div></div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

START-WELSH.
    STRING
        "<div class=""govuk-grid-row""><div class=""govuk-grid-column-two-thirds"">"
        "<div class=""govuk-notification-banner"" role=""region"" "
        "aria-labelledby=""licence-available-title"" "
        "data-module=""govuk-notification-banner"">"
        "<div class=""govuk-notification-banner__header"">"
        "<h2 class=""govuk-notification-banner__title"" "
        "id=""licence-available-title"">Pwysig</h2></div>"
        "<div class=""govuk-notification-banner__content"">"
        "<p class=""govuk-notification-banner__heading"">"
        "Mae trwydded gwialen 2026 i 2027 ar gael nawr.</p></div></div>"
        "<h1 class=""govuk-heading-xl"">Gwneud cais am drwydded bysgota</h1>"
        "<p class=""govuk-body-l"">Defnyddiwch y gwasanaeth hwn i wneud cais am "
        "drwydded i bysgota gyda gwialen.</p>"
        "<a href=""/licence-length"" role=""button"" draggable=""false"" "
        "class=""govuk-button govuk-button--start"" data-module=""govuk-button"">"
        "Dechrau nawr"
        "<svg class=""govuk-button__start-icon"" xmlns=""http://www.w3.org/2000/svg"" "
        "width=""17.5"" height=""19"" viewBox=""0 0 33 40"" aria-hidden=""true"" "
        "focusable=""false""><path fill=""currentColor"" "
        "d=""M0 0h13l20 20-20 20H0l20-20z""/></svg></a>"
        "<p class=""govuk-body"">Mae'n cymryd tua 10 munud.</p>"
        "<div class=""govuk-warning-text"">"
        "<span class=""govuk-warning-text__icon"" aria-hidden=""true"">!</span>"
        "<strong class=""govuk-warning-text__text"">"
        "<span class=""govuk-visually-hidden"">Rhybudd</span>"
        "Rhaid i chi gael trwydded gwialen ddilys cyn i chi bysgota."
        "</strong></div>"
        "<div class=""govuk-inset-text"">"
        "Mae gweddill yr enghraifft hon yn Saesneg."
        "</div>"
        "<details class=""govuk-details"">"
        "<summary class=""govuk-details__summary"">"
        "<span class=""govuk-details__summary-text"">Beth fydd ei angen arnoch</span>"
        "</summary><div class=""govuk-details__text"">"
        "<ul class=""govuk-list govuk-list--bullet"">"
        "<li>Pa mor hir mae angen y drwydded</li><li>Eich enw</li>"
        "<li>Eich dyddiad geni</li><li>Y wlad lle byddwch yn pysgota</li>"
        "<li>Eich cyfeiriad e-bost</li></ul></div></details>"
        "<p class=""govuk-body""><a class=""govuk-link"" href=""/"" hreflang=""en"" "
        "lang=""en"">English</a></p>"
        "</div></div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

RENDER-QUESTION.
    MOVE "en" TO PAGE-LANG
    MOVE 0 TO PAGE-TITLE-LEN
    EVALUATE STEP-ID
        WHEN 2
            MOVE "How long do you need the licence for?" TO PAGE-TITLE
            MOVE 37 TO PAGE-TITLE-LEN
        WHEN 3
            MOVE "What is your full name?" TO PAGE-TITLE
            MOVE 23 TO PAGE-TITLE-LEN
        WHEN 4
            MOVE "What is your date of birth?" TO PAGE-TITLE
            MOVE 27 TO PAGE-TITLE-LEN
        WHEN 5
            MOVE "Where will you fish?" TO PAGE-TITLE
            MOVE 20 TO PAGE-TITLE-LEN
        WHEN 6
            MOVE "What is your email address?" TO PAGE-TITLE
            MOVE 27 TO PAGE-TITLE-LEN
    END-EVALUATE
    IF ERROR-LEN > 0
        MOVE SPACES TO SRC-TEXT
        STRING "Error: " DELIMITED BY SIZE
            PAGE-TITLE(1:PAGE-TITLE-LEN) DELIMITED BY SIZE
            INTO SRC-TEXT
        END-STRING
        MOVE SRC-TEXT TO PAGE-TITLE
        COMPUTE PAGE-TITLE-LEN = PAGE-TITLE-LEN + 7
    END-IF
    PERFORM BEGIN-PAGE
    STRING "<div class=""govuk-grid-row"">"
        "<div class=""govuk-grid-column-two-thirds"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM APPEND-BACK-LINK
    IF ERROR-LEN > 0
        PERFORM APPEND-ERROR-SUMMARY
    END-IF
    STRING "<form method=""post"" novalidate action="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM APPEND-ACTION
    STRING """>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF RETURN-CHECK = "Y"
        STRING "<input type=""hidden"" name=""return"" value=""check-answers"">"
            DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    EVALUATE STEP-ID
        WHEN 2 PERFORM FIELD-LICENCE
        WHEN 3 PERFORM FIELD-NAME
        WHEN 4 PERFORM FIELD-DATE
        WHEN 5 PERFORM FIELD-COUNTRY
        WHEN 6 PERFORM FIELD-EMAIL
    END-EVALUATE
    STRING "<button type=""submit"" class=""govuk-button"" "
        "data-module=""govuk-button"">Continue</button></form></div></div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM END-PAGE.

APPEND-ACTION.
    EVALUATE STEP-ID
        WHEN 2
            STRING "/licence-length" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 3
            STRING "/name" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 4
            STRING "/date-of-birth" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 5
            STRING "/where-you-will-fish" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 6
            STRING "/email" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
    END-EVALUATE.

APPEND-BACK-LINK.
    STRING "<a href=""" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF RETURN-CHECK = "Y"
        STRING "/check-answers" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        EVALUATE STEP-ID
            WHEN 2
                STRING "/" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN 3
                STRING "/licence-length" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN 4
                STRING "/name" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN 5
                STRING "/date-of-birth" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN 6
                STRING "/where-you-will-fish" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
        END-EVALUATE
    END-IF
    STRING """ class=""govuk-back-link"">Back</a>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

APPEND-ERROR-SUMMARY.
    STRING "<div class=""govuk-error-summary"" data-module=""govuk-error-summary"">"
        "<div role=""alert""><h2 class=""govuk-error-summary__title"">"
        "There is a problem</h2><div class=""govuk-error-summary__body"">"
        "<ul class=""govuk-list govuk-error-summary__list""><li><a href=""#"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    EVALUATE STEP-ID
        WHEN 2
            STRING "licence-length" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 3
            STRING "full-name" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 4
            STRING "date-of-birth-day" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 5
            STRING "country" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        WHEN 6
            STRING "email" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
    END-EVALUATE
    STRING """>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE ERROR-TEXT TO SRC-TEXT
    MOVE ERROR-LEN TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING "</a></li></ul></div></div></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-LICENCE.
    PERFORM OPEN-RADIOS
    STRING "How long do you need the licence for?" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM CLOSE-LEGEND
    IF ERROR-LEN > 0
        PERFORM FIELD-ERROR
    END-IF
    STRING "<div class=""govuk-radios"" data-module=""govuk-radios"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE "1-day" TO LABEL-TEXT
    PERFORM RADIO-LENGTH
    MOVE "8-days" TO LABEL-TEXT
    PERFORM RADIO-LENGTH
    MOVE "12-months" TO LABEL-TEXT
    PERFORM RADIO-LENGTH
    STRING "</div></fieldset></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

RADIO-LENGTH.
    IF LABEL-TEXT = "1-day"
        MOVE "licence-length" TO NAME-BUF
        MOVE "1 day" TO VALUE-BUF
    ELSE
        IF LABEL-TEXT = "8-days"
            MOVE "licence-length-2" TO NAME-BUF
            MOVE "8 days" TO VALUE-BUF
        ELSE
            MOVE "licence-length-3" TO NAME-BUF
            MOVE "12 months" TO VALUE-BUF
        END-IF
    END-IF
    IF FORM-LICENCE = LABEL-TEXT
        MOVE "Y" TO CHECKED
    ELSE
        MOVE "N" TO CHECKED
    END-IF
    STRING "<div class=""govuk-radios__item""><input class=""govuk-radios__input"" id="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """ name=""licence-length"" type=""radio"" value="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(LABEL-TEXT) DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF CHECKED = "Y"
        STRING """ checked>" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING """>" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING "<label class=""govuk-label govuk-radios__label"" for="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(VALUE-BUF) DELIMITED BY SIZE
        "</label></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-COUNTRY.
    PERFORM OPEN-RADIOS
    STRING "Where will you fish?" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM CLOSE-LEGEND
    STRING "<div id=""country-hint"" class=""govuk-hint"">"
        "This example is fictional. It does not check a real fishing area.</div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        PERFORM FIELD-ERROR
    END-IF
    STRING "<div class=""govuk-radios"" data-module=""govuk-radios"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE "England" TO LABEL-TEXT
    PERFORM RADIO-COUNTRY
    MOVE "Wales" TO LABEL-TEXT
    PERFORM RADIO-COUNTRY
    MOVE "Scotland" TO LABEL-TEXT
    PERFORM RADIO-COUNTRY
    STRING "</div></fieldset></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

RADIO-COUNTRY.
    IF LABEL-TEXT = "England"
        MOVE "country" TO NAME-BUF
    ELSE
        IF LABEL-TEXT = "Wales"
            MOVE "country-2" TO NAME-BUF
        ELSE
            MOVE "country-3" TO NAME-BUF
        END-IF
    END-IF
    IF FORM-COUNTRY = LABEL-TEXT
        MOVE "Y" TO CHECKED
    ELSE
        MOVE "N" TO CHECKED
    END-IF
    STRING "<div class=""govuk-radios__item"">"
        "<input class=""govuk-radios__input"" id="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """ name=""country"" type=""radio"" value=""" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(LABEL-TEXT) DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF CHECKED = "Y"
        STRING """ checked>" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING """>" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING "<label class=""govuk-label govuk-radios__label"" for="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(LABEL-TEXT) DELIMITED BY SIZE
        "</label></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

OPEN-RADIOS.
    IF ERROR-LEN > 0
        STRING "<div class=""govuk-form-group govuk-form-group--error"">"
            DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING "<div class=""govuk-form-group"">" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING "<fieldset class=""govuk-fieldset"">"
        "<legend class=""govuk-fieldset__legend govuk-fieldset__legend--l"">"
        "<h1 class=""govuk-fieldset__heading"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

CLOSE-LEGEND.
    STRING "</h1></legend>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-ERROR.
    STRING "<p class=""govuk-error-message""><span class=""govuk-visually-hidden"">"
        "Error:</span> " DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE ERROR-TEXT TO SRC-TEXT
    MOVE ERROR-LEN TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING "</p>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-NAME.
    PERFORM OPEN-TEXT
    STRING "<h1 class=""govuk-label-wrapper""><label class=""govuk-label govuk-label--l"" "
        "for=""full-name"">What is your full name?</label></h1>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        PERFORM FIELD-ERROR
    END-IF
    STRING "<input class=""govuk-input" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        STRING " govuk-input--error" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING """ id=""full-name"" name=""full-name"" type=""text"" "
        "autocomplete=""name"" spellcheck=""false"" value="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE FORM-NAME TO SRC-TEXT
    MOVE FORM-NAME-LEN TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING """></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-EMAIL.
    PERFORM OPEN-TEXT
    STRING "<h1 class=""govuk-label-wrapper""><label class=""govuk-label govuk-label--l"" "
        "for=""email"">What is your email address?</label></h1>"
        "<div id=""email-hint"" class=""govuk-hint"">"
        "This example stores the address in your browser session only.</div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        PERFORM FIELD-ERROR
    END-IF
    STRING "<input class=""govuk-input" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        STRING " govuk-input--error" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING """ id=""email"" name=""email"" type=""email"" autocomplete=""email"" "
        "spellcheck=""false"" aria-describedby=""email-hint"" value="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE FORM-EMAIL TO SRC-TEXT
    MOVE FORM-EMAIL-LEN TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING """></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

FIELD-DATE.
    IF ERROR-LEN > 0
        STRING "<div class=""govuk-form-group govuk-form-group--error"">"
            DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING "<div class=""govuk-form-group"">" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING "<fieldset class=""govuk-fieldset"" role=""group"">"
        "<legend class=""govuk-fieldset__legend govuk-fieldset__legend--l"">"
        "<h1 class=""govuk-fieldset__heading"">What is your date of birth?</h1>"
        "</legend><div id=""date-of-birth-hint"" class=""govuk-hint"">"
        "For example, 31 3 1980</div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF ERROR-LEN > 0
        PERFORM FIELD-ERROR
    END-IF
    STRING "<div class=""govuk-date-input"" id=""date-of-birth"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE "day" TO NAME-BUF
    MOVE FORM-DAY TO VALUE-BUF
    MOVE 2 TO HEX-INDEX
    PERFORM DATE-ITEM
    MOVE "month" TO NAME-BUF
    MOVE FORM-MONTH TO VALUE-BUF
    MOVE 2 TO HEX-INDEX
    PERFORM DATE-ITEM
    MOVE "year" TO NAME-BUF
    MOVE FORM-YEAR TO VALUE-BUF
    MOVE 4 TO HEX-INDEX
    PERFORM DATE-ITEM
    STRING "</div></fieldset></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

DATE-ITEM.
    STRING "<div class=""govuk-date-input__item""><div class=""govuk-form-group"">"
        "<label class=""govuk-label govuk-date-input__label"" for=""date-of-birth-"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF NAME-BUF(1:3) = "day"
        STRING "Day" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        IF NAME-BUF(1:5) = "month"
            STRING "Month" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        ELSE
            STRING "Year" DELIMITED BY SIZE
                INTO RES-BODY WITH POINTER BODY-PTR
            END-STRING
        END-IF
    END-IF
    STRING "</label><input class=""govuk-input govuk-date-input__input "
        "govuk-input--width-" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF HEX-INDEX = 4
        STRING "4" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING "2" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    IF ERROR-LEN > 0
        STRING " govuk-input--error" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF
    STRING """ id=""date-of-birth-" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """ name=""date-of-birth-" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        """ type=""text"" inputmode=""numeric"" value="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE VALUE-BUF TO SRC-TEXT
    COMPUTE SRC-LEN = LENGTH(TRIM(VALUE-BUF))
    PERFORM APPEND-ESCAPED
    STRING """></div></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

OPEN-TEXT.
    IF ERROR-LEN > 0
        STRING "<div class=""govuk-form-group govuk-form-group--error"">"
            DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        STRING "<div class=""govuk-form-group"">" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    END-IF.

RENDER-CHECK.
    MOVE "en" TO PAGE-LANG
    MOVE "Check your answers" TO PAGE-TITLE
    MOVE 18 TO PAGE-TITLE-LEN
    PERFORM BEGIN-PAGE
    STRING "<div class=""govuk-grid-row""><div class=""govuk-grid-column-two-thirds"">"
        "<a href=""/email"" class=""govuk-back-link"">Back</a>"
        "<h1 class=""govuk-heading-l"">Check your answers before sending your application</h1>"
        "<form method=""post"" action=""/check-answers"" novalidate>"
        "<dl class=""govuk-summary-list"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE "Licence length" TO NAME-BUF
    PERFORM LICENCE-LABEL
    MOVE LABEL-TEXT TO VALUE-BUF
    MOVE "/licence-length" TO PARTIAL-NAME
    MOVE "licence length" TO ERROR-TEXT
    PERFORM SUMMARY-ROW
    MOVE "Name" TO NAME-BUF
    MOVE SESS-NAME(SLOT) TO VALUE-BUF
    MOVE SESS-NAME-LEN(SLOT) TO VALUE-LEN
    MOVE "/name" TO PARTIAL-NAME
    MOVE "name" TO ERROR-TEXT
    PERFORM SUMMARY-ROW-LEN
    MOVE "Date of birth" TO NAME-BUF
    MOVE SPACES TO VALUE-BUF
    STRING TRIM(SESS-DAY(SLOT)) DELIMITED BY SIZE
        " " DELIMITED BY SIZE
        TRIM(SESS-MONTH(SLOT)) DELIMITED BY SIZE
        " " DELIMITED BY SIZE
        TRIM(SESS-YEAR(SLOT)) DELIMITED BY SIZE
        INTO VALUE-BUF
    END-STRING
    COMPUTE VALUE-LEN = LENGTH(TRIM(VALUE-BUF))
    MOVE "/date-of-birth" TO PARTIAL-NAME
    MOVE "date of birth" TO ERROR-TEXT
    PERFORM SUMMARY-ROW-LEN
    MOVE "Where you will fish" TO NAME-BUF
    MOVE SESS-COUNTRY(SLOT) TO VALUE-BUF
    COMPUTE VALUE-LEN = LENGTH(TRIM(VALUE-BUF))
    MOVE "/where-you-will-fish" TO PARTIAL-NAME
    MOVE "where you will fish" TO ERROR-TEXT
    PERFORM SUMMARY-ROW-LEN
    MOVE "Email address" TO NAME-BUF
    MOVE SESS-EMAIL(SLOT) TO VALUE-BUF
    MOVE SESS-EMAIL-LEN(SLOT) TO VALUE-LEN
    MOVE "/email" TO PARTIAL-NAME
    MOVE "email address" TO ERROR-TEXT
    PERFORM SUMMARY-ROW-LEN
    STRING "</dl><button type=""submit"" class=""govuk-button"" "
        "data-module=""govuk-button"">Accept and continue</button>"
        "</form></div></div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM END-PAGE.

LICENCE-LABEL.
    EVALUATE SESS-LICENCE(SLOT)
        WHEN "1-day"
            MOVE "1 day" TO LABEL-TEXT
        WHEN "8-days"
            MOVE "8 days" TO LABEL-TEXT
        WHEN "12-months"
            MOVE "12 months" TO LABEL-TEXT
        WHEN OTHER
            MOVE "Not provided" TO LABEL-TEXT
    END-EVALUATE.

SUMMARY-ROW.
    COMPUTE VALUE-LEN = LENGTH(TRIM(VALUE-BUF))
    PERFORM SUMMARY-ROW-LEN.

SUMMARY-ROW-LEN.
    STRING "<div class=""govuk-summary-list__row"">"
        "<dt class=""govuk-summary-list__key"">"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(NAME-BUF) DELIMITED BY SIZE
        "</dt><dd class=""govuk-summary-list__value"">" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF VALUE-LEN = 0
        STRING "Not provided" DELIMITED BY SIZE
            INTO RES-BODY WITH POINTER BODY-PTR
        END-STRING
    ELSE
        MOVE VALUE-BUF TO SRC-TEXT
        MOVE VALUE-LEN TO SRC-LEN
        PERFORM APPEND-ESCAPED
    END-IF
    STRING "</dd><dd class=""govuk-summary-list__actions"">"
        "<a class=""govuk-link"" href="""
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(PARTIAL-NAME) DELIMITED BY SIZE
        "?return=check-answers"">Change" DELIMITED BY SIZE
        "<span class=""govuk-visually-hidden""> " DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING TRIM(ERROR-TEXT) DELIMITED BY SIZE
        "</span></a></dd></div>" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING.

RENDER-CONFIRMATION.
    MOVE "en" TO PAGE-LANG
    MOVE "Application complete" TO PAGE-TITLE
    MOVE 20 TO PAGE-TITLE-LEN
    PERFORM BEGIN-PAGE
    STRING "<div class=""govuk-grid-row""><div class=""govuk-grid-column-two-thirds"">"
        "<div class=""govuk-panel govuk-panel--confirmation"">"
        "<h1 class=""govuk-panel__title"">Application complete</h1>"
        "<div class=""govuk-panel__body"">Your example reference number<br><strong>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE SESS-REFERENCE(SLOT) TO SRC-TEXT
    MOVE 10 TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING "</strong></div></div>"
        "<p class=""govuk-body"">This is a fictional example. "
        "Nobody will send you a fishing rod licence.</p>"
        "<p class=""govuk-body""><a class=""govuk-link"" href=""/components"">"
        "Back to the component list</a></p></div></div>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    PERFORM END-PAGE.

BEGIN-PAGE.
    MOVE SPACES TO RES-BODY
    MOVE 1 TO BODY-PTR
    MOVE "Y" TO RES-HAS-BODY
    MOVE "N" TO RES-HAS-FILE
    MOVE 200 TO RES-STATUS
    MOVE "Y" TO RES-NO-STORE
    MOVE "text/html; charset=utf-8" TO RES-CONTENT-TYPE
    STRING "<!DOCTYPE html><html lang=""" DELIMITED BY SIZE
        INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    STRING PAGE-LANG DELIMITED BY SIZE
        """ class=""govuk-template""><head><meta charset=""utf-8""><title>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    MOVE PAGE-TITLE TO SRC-TEXT
    MOVE PAGE-TITLE-LEN TO SRC-LEN
    PERFORM APPEND-ESCAPED
    STRING "</title>"
        "<meta name=""viewport"" content=""width=device-width, initial-scale=1, viewport-fit=cover"">"
        "<meta name=""theme-color"" content=""#1d70b8"">"
        "<meta name=""robots"" content=""noindex, nofollow"">"
        "<link rel=""icon"" sizes=""48x48"" href=""/assets/images/favicon.ico"">"
        "<link rel=""icon"" sizes=""any"" href=""/assets/images/favicon.svg"" type=""image/svg+xml"">"
        "<link rel=""mask-icon"" href=""/assets/images/govuk-icon-mask.svg"" color=""#1d70b8"">"
        "<link rel=""apple-touch-icon"" href=""/assets/images/govuk-icon-180.png"">"
        "<link rel=""manifest"" href=""/assets/manifest.json"">"
        "<link rel=""stylesheet"" href=""/assets/govuk-frontend.min.css"">"
        "<link rel=""stylesheet"" href=""/assets/application.css"">"
        "</head>"
        DELIMITED BY SIZE INTO RES-BODY WITH POINTER BODY-PTR
    END-STRING
    IF PAGE-LANG = "cy"
        MOVE "/partials/top-cy.html" TO PARTIAL-NAME
        MOVE 21 TO PARTIAL-LEN
    ELSE
        MOVE "/partials/top.html" TO PARTIAL-NAME
        MOVE 18 TO PARTIAL-LEN
    END-IF
    PERFORM APPEND-PARTIAL.

END-PAGE.
    MOVE "/partials/bottom.html" TO PARTIAL-NAME
    MOVE 21 TO PARTIAL-LEN
    PERFORM APPEND-PARTIAL
    COMPUTE RES-BODY-LEN = BODY-PTR - 1.

APPEND-PARTIAL.
    MOVE SPACES TO FILE-PATH
    MOVE CANON-ROOT(1:CANON-ROOT-LEN) TO FILE-PATH
    MOVE PARTIAL-NAME(1:PARTIAL-LEN)
        TO FILE-PATH(CANON-ROOT-LEN + 1:PARTIAL-LEN)
    MOVE LOW-VALUE TO FILE-PATH(CANON-ROOT-LEN + PARTIAL-LEN + 1:1)
    CALL "GWS_OPEN_FILE" USING BY REFERENCE FILE-PATH RETURNING FILE-FD
    IF FILE-FD < 0
        MOVE 500 TO RES-STATUS
        EXIT PARAGRAPH
    END-IF
    PERFORM UNTIL READ-COUNT < 0
        CALL "GWS_READ" USING
            BY VALUE FILE-FD
            BY REFERENCE IO-BUF
            BY VALUE CHUNK-SIZE
            RETURNING READ-COUNT
        IF READ-COUNT <= 0
            MOVE -1 TO READ-COUNT
        ELSE
            IF BODY-PTR + READ-COUNT > 32768
                MOVE 500 TO RES-STATUS
                MOVE -1 TO READ-COUNT
            ELSE
                MOVE IO-BUF(1:READ-COUNT) TO RES-BODY(BODY-PTR:READ-COUNT)
                ADD READ-COUNT TO BODY-PTR
            END-IF
        END-IF
    END-PERFORM
    CALL "GWS_CLOSE" USING BY VALUE FILE-FD
    MOVE 0 TO READ-COUNT.

APPEND-ESCAPED.
    PERFORM VARYING SCAN FROM 1 BY 1 UNTIL SCAN > SRC-LEN
        EVALUATE SRC-TEXT(SCAN:1)
            WHEN "&"
                STRING "&amp;" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN "<"
                STRING "&lt;" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN ">"
                STRING "&gt;" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN """"
                STRING "&quot;" DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
            WHEN OTHER
                STRING SRC-TEXT(SCAN:1) DELIMITED BY SIZE
                    INTO RES-BODY WITH POINTER BODY-PTR
                END-STRING
        END-EVALUATE
    END-PERFORM.

END PROGRAM JOURNEY.
