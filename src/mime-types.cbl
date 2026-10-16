IDENTIFICATION DIVISION.
PROGRAM-ID. MIME-TYPES.

ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
REPOSITORY.
    FUNCTION ALL INTRINSIC.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 POS                         PIC S9(9) COMP-5 VALUE 0.
01 DOT-POS                     PIC S9(9) COMP-5 VALUE 0.
01 SLASH-POS                   PIC S9(9) COMP-5 VALUE 0.
01 EXT-LEN                     PIC S9(9) COMP-5 VALUE 0.
01 EXTENSION                   PIC X(16) VALUE SPACES.

LINKAGE SECTION.
COPY "http.cpy".

PROCEDURE DIVISION USING SERVER-CONTEXT.
CHOOSE-TYPE.
    MOVE "application/octet-stream" TO RES-CONTENT-TYPE
    MOVE 0 TO DOT-POS
    MOVE 0 TO SLASH-POS
    IF RES-FILE-PATH-LEN < 1
        EXIT PROGRAM
    END-IF
    PERFORM VARYING POS FROM 1 BY 1 UNTIL POS > RES-FILE-PATH-LEN
        IF RES-FILE-PATH(POS:1) = "."
            MOVE POS TO DOT-POS
        END-IF
        IF RES-FILE-PATH(POS:1) = "/"
            MOVE POS TO SLASH-POS
        END-IF
    END-PERFORM
    IF DOT-POS = 0 OR DOT-POS < SLASH-POS OR DOT-POS = RES-FILE-PATH-LEN
        EXIT PROGRAM
    END-IF
    COMPUTE EXT-LEN = RES-FILE-PATH-LEN - DOT-POS
    IF EXT-LEN > 16
        EXIT PROGRAM
    END-IF
    MOVE SPACES TO EXTENSION
    MOVE LOWER-CASE(RES-FILE-PATH(DOT-POS + 1:EXT-LEN)) TO EXTENSION
    EVALUATE EXTENSION
        WHEN "html"
            MOVE "text/html; charset=utf-8" TO RES-CONTENT-TYPE
        WHEN "css"
            MOVE "text/css; charset=utf-8" TO RES-CONTENT-TYPE
        WHEN "js"
            MOVE "text/javascript; charset=utf-8" TO RES-CONTENT-TYPE
        WHEN "mjs"
            MOVE "text/javascript; charset=utf-8" TO RES-CONTENT-TYPE
        WHEN "json"
            MOVE "application/json" TO RES-CONTENT-TYPE
        WHEN "map"
            MOVE "application/json" TO RES-CONTENT-TYPE
        WHEN "svg"
            MOVE "image/svg+xml" TO RES-CONTENT-TYPE
        WHEN "png"
            MOVE "image/png" TO RES-CONTENT-TYPE
        WHEN "jpg"
            MOVE "image/jpeg" TO RES-CONTENT-TYPE
        WHEN "jpeg"
            MOVE "image/jpeg" TO RES-CONTENT-TYPE
        WHEN "gif"
            MOVE "image/gif" TO RES-CONTENT-TYPE
        WHEN "webp"
            MOVE "image/webp" TO RES-CONTENT-TYPE
        WHEN "ico"
            MOVE "image/x-icon" TO RES-CONTENT-TYPE
        WHEN "woff"
            MOVE "font/woff" TO RES-CONTENT-TYPE
        WHEN "woff2"
            MOVE "font/woff2" TO RES-CONTENT-TYPE
        WHEN OTHER
            MOVE "application/octet-stream" TO RES-CONTENT-TYPE
    END-EVALUATE
    EXIT PROGRAM.

END PROGRAM MIME-TYPES.
