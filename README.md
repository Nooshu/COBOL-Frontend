# COBOL Frontend

A COBOL web server for an example GOV.UK service, **Apply for a fishing rod licence**, plus a site generated from the [GOV.UK Frontend](https://design-system.service.gov.uk/) 6.6.0 test fixtures.

The licence journey is rendered by COBOL. Answers are kept in memory for the life of the process and tied to a `session` cookie. The service does not take payment, send email, or issue a real licence. The fixture catalogue, fees page, CSS, JavaScript, fonts, and images are static files. A Node script runs at image build time, reads each component's `fixtures.json`, and writes one HTML page per fixture inside the GOV.UK page template. Interactive components are started with `initAll()`.

## Run with Docker

Docker is the supported way to run the server. The image builds the fixture site, compiles the COBOL program with GnuCOBOL, and listens on port 8080.

```sh
docker compose up --build
```

Open [http://127.0.0.1:8080](http://127.0.0.1:8080). Start now walks through licence length, name, date of birth, where you will fish, and email, then check your answers and a confirmation reference. `/cy` is the Welsh start page. The rest of the journey is in English. Invalid answers stay on the same question. `/fees` lists the example prices. `/components` is the fixture catalogue. Fixtures marked hidden by GOV.UK Frontend are listed separately, because they are not visually distinct. Each component's original `fixtures.json` is served under `/fixtures/`.

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

The server handles one request at a time. Journey pages accept `GET`, `HEAD`, and `POST`. Other paths accept `GET` and `HEAD`, and reject `POST` with 405. Paths that leave the document root are refused. `PORT` defaults to 8080 and `DOCUMENT_ROOT` defaults to `site`. Journey HTML is not cached (`Cache-Control: no-store`). HTML responses send `X-Robots-Tag: noindex, nofollow`, and `/robots.txt` disallows every path.
