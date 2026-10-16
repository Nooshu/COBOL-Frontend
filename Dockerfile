FROM node:22-bookworm-slim AS site
WORKDIR /src
COPY package.json package-lock.json ./
RUN npm ci
COPY scripts/build-site.mjs scripts/build-site.mjs
RUN node scripts/build-site.mjs

FROM debian:stable-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends gnucobol gcc libc6-dev make \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY Makefile Makefile
COPY src src
COPY copy copy
COPY c c
RUN make \
    && install -m 0755 bin/govuk-server /usr/local/bin/govuk-server \
    && useradd --system --no-create-home --shell /usr/sbin/nologin govuk
COPY --from=site /src/site /srv/site
RUN chown -R govuk:govuk /srv/site
USER govuk
WORKDIR /srv
ENV PORT=8080
ENV DOCUMENT_ROOT=/srv/site
EXPOSE 8080
CMD ["govuk-server"]
