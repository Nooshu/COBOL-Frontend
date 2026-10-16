#!/bin/sh
set -eu

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

code=$(curl -sS -D "$tmp/index.headers" -o "$tmp/index.html" -w "%{http_code}" "$BASE_URL/")
test "$code" = "200" || fail "GET / returned $code"
grep -q "GOV.UK Frontend fixtures" "$tmp/index.html" || fail "catalogue page has no title"
grep -qi "content-type: text/html" "$tmp/index.headers" || fail "catalogue content type"
grep -qi "x-content-type-options: nosniff" "$tmp/index.headers" || fail "missing nosniff"

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

code=$(curl -sS -D "$tmp/post.headers" -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/")
test "$code" = "405" || fail "POST returned $code"
grep -qi "allow: GET, HEAD" "$tmp/post.headers" || fail "POST is missing Allow"

code=$(curl -sS -o /dev/null -w "%{http_code}" --path-as-is "$BASE_URL/../../etc/passwd")
test "$code" = "400" || fail "traversal returned $code"

code=$(curl -sS -o /dev/null -w "%{http_code}" --path-as-is "$BASE_URL/assets/%2e%2e/%2e%2e/etc/passwd")
test "$code" = "400" || fail "encoded traversal returned $code"

echo "Smoke tests passed"
