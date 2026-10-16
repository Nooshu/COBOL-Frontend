#!/bin/sh
set -eu

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

code=$(curl -sS -D "$tmp/index.headers" -o "$tmp/index.html" -c "$tmp/cookies" -w "%{http_code}" "$BASE_URL/")
test "$code" = "200" || fail "GET / returned $code"
grep -q "Apply for a fishing rod licence" "$tmp/index.html" || fail "start page has no service name"
grep -q "Start now" "$tmp/index.html" || fail "start page has no Start now"
grep -qi "content-type: text/html" "$tmp/index.headers" || fail "start page content type"
grep -qi "x-content-type-options: nosniff" "$tmp/index.headers" || fail "missing nosniff"
grep -qi "set-cookie: session=" "$tmp/index.headers" || fail "start page did not set a session"
grep -qi "cache-control: no-store" "$tmp/index.headers" || fail "start page is cacheable"
grep -qi "x-robots-tag: noindex, nofollow" "$tmp/index.headers" || fail "missing robots tag"

code=$(curl -sS -o "$tmp/cy.html" -w "%{http_code}" "$BASE_URL/cy")
test "$code" = "200" || fail "GET /cy returned $code"
grep -q "Dechrau nawr" "$tmp/cy.html" || fail "Welsh start page is missing"

code=$(curl -sS -o "$tmp/catalogue.html" -w "%{http_code}" "$BASE_URL/components")
test "$code" = "200" || fail "GET /components returned $code"
grep -q "GOV.UK Frontend fixtures" "$tmp/catalogue.html" || fail "catalogue page has no title"

code=$(curl -sS -o "$tmp/fees.html" -w "%{http_code}" "$BASE_URL/fees")
test "$code" = "200" || fail "GET /fees returned $code"
grep -q "7.10" "$tmp/fees.html" || fail "fees page is missing the day fee"

code=$(curl -sS -o "$tmp/robots.txt" -w "%{http_code}" "$BASE_URL/robots.txt")
test "$code" = "200" || fail "GET /robots.txt returned $code"
grep -q "Disallow: /" "$tmp/robots.txt" || fail "robots.txt does not disallow /"

code=$(curl -sS -o "$tmp/button.html" -w "%{http_code}" "$BASE_URL/components/button/default.html")
test "$code" = "200" || fail "button fixture returned $code"
grep -q "govuk-button" "$tmp/button.html" || fail "button fixture is missing govuk-button"

code=$(curl -sS -D "$tmp/css.headers" -o "$tmp/app.css" -w "%{http_code}" "$BASE_URL/assets/govuk-frontend.min.css")
test "$code" = "200" || fail "CSS returned $code"
grep -qi "content-type: text/css" "$tmp/css.headers" || fail "CSS content type"
test -s "$tmp/app.css" || fail "CSS body is empty"

code=$(curl -sS -D "$tmp/js.headers" -o "$tmp/app.js" -w "%{http_code}" "$BASE_URL/assets/govuk-frontend.min.js")
test "$code" = "200" || fail "JavaScript returned $code"
grep -qi "content-type: text/javascript" "$tmp/js.headers" || fail "JavaScript content type"
test -s "$tmp/app.js" || fail "JavaScript body is empty"

font=$(grep -oE '/assets/fonts/[^)" ]+\.woff2' "$tmp/app.css" | head -n 1)
test -n "$font" || fail "CSS has no woff2 font"
code=$(curl -sS -D "$tmp/font.headers" -o "$tmp/font.woff2" -w "%{http_code}" "$BASE_URL$font")
test "$code" = "200" || fail "font $font returned $code"
grep -qi "content-type: font/woff2" "$tmp/font.headers" || fail "font content type"
test -s "$tmp/font.woff2" || fail "font body is empty"

code=$(curl -sS -o /dev/null -w "%{http_code}" "$BASE_URL/missing-file.html")
test "$code" = "404" || fail "missing file returned $code"

code=$(curl -sS -D "$tmp/post.headers" -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/components/button/default.html")
test "$code" = "405" || fail "POST returned $code"
grep -qi "allow: GET, HEAD" "$tmp/post.headers" || fail "POST is missing Allow"

code=$(curl -sS -D "$tmp/guard.headers" -o /dev/null -b "$tmp/cookies" -w "%{http_code}" "$BASE_URL/email")
test "$code" = "303" || fail "GET /email before licence length returned $code"
grep -qi "location: /licence-length" "$tmp/guard.headers" || fail "guard did not send the user to licence length"

code=$(curl -sS -D "$tmp/bad.headers" -o "$tmp/bad.html" -b "$tmp/cookies" -c "$tmp/cookies" -w "%{http_code}" \
  -X POST "$BASE_URL/licence-length" -d "")
test "$code" = "200" || fail "invalid licence length returned $code"
grep -q "There is a problem" "$tmp/bad.html" || fail "invalid licence length has no error summary"
grep -q "Select how long you need the licence for" "$tmp/bad.html" || fail "invalid licence length has no message"

post() {
  code=$(curl -sS -D "$tmp/step.headers" -o "$tmp/step.html" -b "$tmp/cookies" -c "$tmp/cookies" -w "%{http_code}" \
    -X POST "$BASE_URL$1" --data-urlencode "$2" ${3:+--data-urlencode "$3"} ${4:+--data-urlencode "$4"})
  test "$code" = "303" || fail "POST $1 returned $code"
  grep -qi "location: $5" "$tmp/step.headers" || fail "POST $1 location was not $5"
}

post /licence-length "licence-length=1-day" "" "" /name
post /name "full-name=Ada Lovelace" "" "" /date-of-birth
post /date-of-birth "date-of-birth-day=31" "date-of-birth-month=3" "date-of-birth-year=1980" /where-you-will-fish
post /where-you-will-fish "country=England" "" "" /email
post /email "email=ada@example.com" "" "" /check-answers

code=$(curl -sS -o "$tmp/check.html" -b "$tmp/cookies" -w "%{http_code}" "$BASE_URL/check-answers")
test "$code" = "200" || fail "GET /check-answers returned $code"
grep -q "Ada Lovelace" "$tmp/check.html" || fail "check answers is missing the name"
grep -q "1 day" "$tmp/check.html" || fail "check answers is missing the licence"
grep -q "England" "$tmp/check.html" || fail "check answers is missing the country"

code=$(curl -sS -D "$tmp/confirm.headers" -o /dev/null -b "$tmp/cookies" -c "$tmp/cookies" -w "%{http_code}" \
  -X POST "$BASE_URL/check-answers")
test "$code" = "303" || fail "POST /check-answers returned $code"
grep -qi "location: /confirmation" "$tmp/confirm.headers" || fail "confirmation redirect missing"

code=$(curl -sS -o "$tmp/confirm.html" -b "$tmp/cookies" -w "%{http_code}" "$BASE_URL/confirmation")
test "$code" = "200" || fail "GET /confirmation returned $code"
grep -q "FRL-" "$tmp/confirm.html" || fail "confirmation has no reference"

code=$(curl -sS -D "$tmp/blocked.headers" -o /dev/null -w "%{http_code}" "$BASE_URL/confirmation")
test "$code" = "303" || fail "confirmation without a session returned $code"
grep -qi "location: /" "$tmp/blocked.headers" || fail "confirmation without a session did not return home"

code=$(curl -sS -o /dev/null -w "%{http_code}" --path-as-is "$BASE_URL/../../etc/passwd")
test "$code" = "400" || fail "traversal returned $code"

code=$(curl -sS -o /dev/null -w "%{http_code}" --path-as-is "$BASE_URL/assets/%2e%2e/%2e%2e/etc/passwd")
test "$code" = "400" || fail "encoded traversal returned $code"

echo "Smoke tests passed"
