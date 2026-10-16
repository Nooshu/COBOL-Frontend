COBC = cobc
SOURCES = src/server.cbl src/http-request.cbl src/http-response.cbl \
	src/static-file.cbl src/mime-types.cbl

bin/govuk-server: $(SOURCES) c/posix_io.c copy/http.cpy copy/config.cpy
	mkdir -p bin
	$(COBC) -x -free -O2 -I copy -o $@ $(SOURCES) c/posix_io.c

.PHONY: clean
clean:
	rm -rf bin
