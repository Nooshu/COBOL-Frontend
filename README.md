# COBOL Frontend

A static web server written in COBOL. It serves a site generated from the [GOV.UK Frontend](https://design-system.service.gov.uk/) 6.6.0 test fixtures, including the CSS, JavaScript, fonts, and images those components need.

The COBOL program accepts HTTP connections and serves files. A Node script runs at image build time, reads each component's `fixtures.json`, and writes one HTML page per fixture inside the GOV.UK page template. Interactive components are started with `initAll()`.

## Run with Docker

Docker is the supported way to run the server. The image builds the fixture site, compiles the COBOL program with GnuCOBOL, and listens on port 8080.

```sh
docker compose up --build
```

Open [http://127.0.0.1:8080](http://127.0.0.1:8080). The catalogue links to every component fixture. Fixtures marked hidden by GOV.UK Frontend are listed separately, because they are not visually distinct. Each component's original `fixtures.json` is served under `/fixtures/`.

With the server running:

```sh
./scripts/smoke-test.sh
```

## Local build

The same binary can be compiled on Linux, or on macOS with GnuCOBOL installed. `sockaddr` and `stat` layouts stay in `c/posix_io.c`, so the COBOL code is the same on both.

```sh
npm ci
npm run build:site
make
DOCUMENT_ROOT=site PORT=8080 ./bin/govuk-server
```

## HTTP behaviour

The server handles one request at a time. It accepts `GET` and `HEAD`, rejects other methods with 405, and refuses paths that leave the document root. `PORT` defaults to 8080 and `DOCUMENT_ROOT` defaults to `site`.
