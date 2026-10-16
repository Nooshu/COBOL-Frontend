import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const packageRoot = path.join(root, "node_modules", "govuk-frontend", "dist", "govuk")
const componentsDir = path.join(packageRoot, "components")
const siteDir = path.join(root, "site")

const cssPath = path.join(packageRoot, "govuk-frontend.min.css")
const css = fs.readFileSync(cssPath, "utf8")
if (!css.includes("url(/assets/")) {
  throw new Error("Expected govuk-frontend.min.css to reference absolute /assets/ URLs")
}

const headerHtml = fixtureHtml("header", "default").replaceAll(
  'href="//gov.uk"',
  'href="/"',
)
const footerHtml = fixtureHtml("footer", "default")

function fixtureHtml(component, name) {
  const fixtures = JSON.parse(
    fs.readFileSync(path.join(componentsDir, component, "fixtures.json"), "utf8"),
  )
  const match = fixtures.fixtures.find((fixture) => fixture.name === name)
  if (!match) {
    throw new Error(`Missing ${component} fixture ${name}`)
  }
  return match.html
}

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
}

function label(name) {
  const text = name.replaceAll("-", " ")
  return text.charAt(0).toUpperCase() + text.slice(1)
}

function slug(name) {
  const value = name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
  return value || "fixture"
}

function page(title, content) {
  return `<!DOCTYPE html>
<html lang="en" class="govuk-template">
  <head>
    <meta charset="utf-8">
    <title>${escapeHtml(title)}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="theme-color" content="#1d70b8">
    <meta name="robots" content="noindex, nofollow">
    <link rel="icon" sizes="48x48" href="/assets/images/favicon.ico">
    <link rel="icon" sizes="any" href="/assets/images/favicon.svg" type="image/svg+xml">
    <link rel="mask-icon" href="/assets/images/govuk-icon-mask.svg" color="#1d70b8">
    <link rel="apple-touch-icon" href="/assets/images/govuk-icon-180.png">
    <link rel="manifest" href="/assets/manifest.json">
    <link rel="stylesheet" href="/assets/govuk-frontend.min.css">
    <link rel="stylesheet" href="/assets/application.css">
  </head>
  <body class="govuk-template__body">
    <script>document.body.className += ' js-enabled' + ('noModule' in HTMLScriptElement.prototype ? ' govuk-frontend-supported' : '');</script>
    <a href="#main-content" class="govuk-skip-link" data-module="govuk-skip-link">Skip to main content</a>
    <header class="govuk-template__header">
${headerHtml}
      <section aria-label="Service information" class="govuk-service-navigation" data-module="govuk-service-navigation">
        <div class="govuk-width-container">
          <div class="govuk-service-navigation__container">
            <span class="govuk-service-navigation__service-name">
              <a href="/" class="govuk-service-navigation__link">Apply for a fishing rod licence</a>
            </span>
          </div>
        </div>
      </section>
    </header>
    <div class="govuk-width-container">
      <div class="govuk-phase-banner">
        <p class="govuk-phase-banner__content">
          <strong class="govuk-tag govuk-phase-banner__content__tag">Example</strong>
          <span class="govuk-phase-banner__text">This is a demonstration – it is not a live government service.</span>
        </p>
      </div>
      <main class="govuk-main-wrapper" id="main-content">
        <div class="govuk-notification-banner app-demo-banner" role="region" aria-labelledby="app-demo-banner-title" data-module="govuk-notification-banner">
          <div class="govuk-notification-banner__header">
            <h2 class="govuk-notification-banner__title" id="app-demo-banner-title">Important</h2>
          </div>
          <div class="govuk-notification-banner__content">
            <p class="govuk-notification-banner__heading">This is a live demo. It is not a real government service.</p>
          </div>
        </div>
${content}
      </main>
    </div>
    <footer class="govuk-template__footer">
      <div class="govuk-width-container">
        <ul class="govuk-footer__inline-list">
          <li class="govuk-footer__inline-list-item"><a class="govuk-footer__link" href="/fees">Licence fees</a></li>
          <li class="govuk-footer__inline-list-item"><a class="govuk-footer__link" href="/components">Component catalogue</a></li>
        </ul>
      </div>
${footerHtml}
    </footer>
    <script type="module" src="/assets/govuk-frontend.min.js"></script>
    <script type="module">
      import { initAll } from "/assets/govuk-frontend.min.js"
      initAll()
    </script>
  </body>
</html>
`
}

function componentList(components) {
  return components.map((component) => {
    const visible = component.fixtures.filter((fixture) => !fixture.hidden)
    const hidden = component.fixtures.filter((fixture) => fixture.hidden)
    const items = (fixtures) => fixtures.map((fixture) =>
      `        <li><a class="govuk-link" href="${fixture.href}">${escapeHtml(fixture.name)}</a></li>`,
    ).join("\n")
    const hiddenSection = hidden.length === 0 ? "" : `
    <h3 class="govuk-heading-s">Hidden fixtures</h3>
    <p class="govuk-body">These fixtures are not visually distinct. GOV.UK Frontend excludes them from visual tests.</p>
    <ul class="govuk-list">
${items(hidden)}
    </ul>`
    return `    <h2 class="govuk-heading-l" id="${escapeHtml(component.name)}">${escapeHtml(label(component.name))}</h2>
    <ul class="govuk-list">
${items(visible)}
    </ul>${hiddenSection}`
  }).join("\n")
}

fs.rmSync(siteDir, { recursive: true, force: true })
fs.mkdirSync(path.join(siteDir, "components"), { recursive: true })
fs.mkdirSync(path.join(siteDir, "fixtures"), { recursive: true })
fs.cpSync(path.join(packageRoot, "assets"), path.join(siteDir, "assets"), { recursive: true })
fs.copyFileSync(cssPath, path.join(siteDir, "assets", "govuk-frontend.min.css"))
fs.copyFileSync(
  path.join(packageRoot, "govuk-frontend.min.js"),
  path.join(siteDir, "assets", "govuk-frontend.min.js"),
)

const components = fs.readdirSync(componentsDir, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .filter((name) => fs.existsSync(path.join(componentsDir, name, "fixtures.json")))
  .sort()
  .map((name) => {
    const fixturePath = path.join(componentsDir, name, "fixtures.json")
    const document = JSON.parse(fs.readFileSync(fixturePath, "utf8"))
    fs.copyFileSync(fixturePath, path.join(siteDir, "fixtures", `${name}.json`))
    const used = new Set()
    const fixtures = document.fixtures.map((fixture) => {
      let fileName = slug(fixture.name)
      let suffix = 2
      while (used.has(fileName)) {
        fileName = `${slug(fixture.name)}-${suffix}`
        suffix += 1
      }
      used.add(fileName)
      const href = `/components/${name}/${fileName}.html`
      const title = `${fixture.name} – ${label(name)} – GOV.UK Frontend`
      fs.mkdirSync(path.join(siteDir, "components", name), { recursive: true })
      fs.writeFileSync(
        path.join(siteDir, "components", name, `${fileName}.html`),
        page(title, fixture.html),
      )
      return {
        name: fixture.name,
        hidden: Boolean(fixture.hidden),
        href,
      }
    })
    return { name, fixtures }
  })

const index = page(
  "GOV.UK Frontend fixtures",
  `    <h1 class="govuk-heading-xl">GOV.UK Frontend fixtures</h1>
    <p class="govuk-body">Examples rendered from the GOV.UK Frontend 6.6.0 test fixtures. Expected HTML for each component is also available as JSON.</p>
${componentList(components)}
    <h2 class="govuk-heading-l">Fixture JSON</h2>
    <ul class="govuk-list">
${components.map((component) => `      <li><a class="govuk-link" href="/fixtures/${component.name}.json">${escapeHtml(label(component.name))}</a></li>`).join("\n")}
    </ul>`,
)

fs.mkdirSync(path.join(siteDir, "partials"), { recursive: true })
fs.mkdirSync(path.join(siteDir, "fees"), { recursive: true })
fs.writeFileSync(path.join(siteDir, "components", "index.html"), index)
fs.writeFileSync(path.join(siteDir, "robots.txt"), "User-agent: *\nDisallow: /\n")
fs.writeFileSync(
  path.join(siteDir, "assets", "application.css"),
  `.app-demo-banner {
  border-color: #fd0;
  background: #fff7bf;
}

.app-demo-banner .govuk-notification-banner__header {
  background-color: #fd0;
}

.app-demo-banner .govuk-notification-banner__title {
  color: #0b0c0c;
}
`,
)
fs.writeFileSync(path.join(siteDir, "partials", "top.html"), chromeTop("en"))
fs.writeFileSync(path.join(siteDir, "partials", "top-cy.html"), chromeTop("cy"))
fs.writeFileSync(path.join(siteDir, "partials", "bottom.html"), chromeBottom())
fs.writeFileSync(
  path.join(siteDir, "fees", "index.html"),
  page(
    "Licence fees – Apply for a fishing rod licence",
    `    <h1 class="govuk-heading-xl">Licence fees</h1>
    <p class="govuk-body">These are example fees. This service does not take payment.</p>
    <table class="govuk-table">
      <caption class="govuk-table__caption govuk-table__caption--m">Rod licence fees</caption>
      <thead class="govuk-table__head">
        <tr class="govuk-table__row">
          <th scope="col" class="govuk-table__header">Licence</th>
          <th scope="col" class="govuk-table__header govuk-table__header--numeric">Fee</th>
        </tr>
      </thead>
      <tbody class="govuk-table__body">
        <tr class="govuk-table__row"><th scope="row" class="govuk-table__header">1 day</th><td class="govuk-table__cell govuk-table__cell--numeric">£7.10</td></tr>
        <tr class="govuk-table__row"><th scope="row" class="govuk-table__header">8 days</th><td class="govuk-table__cell govuk-table__cell--numeric">£14.20</td></tr>
        <tr class="govuk-table__row"><th scope="row" class="govuk-table__header">12 months</th><td class="govuk-table__cell govuk-table__cell--numeric">£36.80</td></tr>
      </tbody>
    </table>
    <p class="govuk-body"><a class="govuk-link" href="/">Back to the start page</a></p>`,
  ),
)
console.log(`Wrote ${components.length} components to ${siteDir}`)

function chromeTop(lang) {
  const welsh = lang === "cy"
  const skip = welsh ? "Neidio i'r prif gynnwys" : "Skip to main content"
  const service = welsh ? "Gwneud cais am drwydded bysgota" : "Apply for a fishing rod licence"
  const home = welsh ? "/cy" : "/"
  const phaseTag = welsh ? "Enghraifft" : "Example"
  const phaseText = welsh
    ? "Mae hon yn arddangosiad – nid gwasanaeth llywodraeth byw mohono."
    : "This is a demonstration – it is not a live government service."
  const bannerTitle = welsh ? "Pwysig" : "Important"
  const bannerText = welsh
    ? "Mae hwn yn arddangosiad byw. Nid gwasanaeth llywodraeth go iawn mohono."
    : "This is a live demo. It is not a real government service."
  return `<body class="govuk-template__body">
    <script>document.body.className += ' js-enabled' + ('noModule' in HTMLScriptElement.prototype ? ' govuk-frontend-supported' : '');</script>
    <a href="#main-content" class="govuk-skip-link" data-module="govuk-skip-link">${skip}</a>
    <header class="govuk-template__header">
${headerHtml}
      <section aria-label="Service information" class="govuk-service-navigation" data-module="govuk-service-navigation">
        <div class="govuk-width-container">
          <div class="govuk-service-navigation__container">
            <span class="govuk-service-navigation__service-name">
              <a href="${home}" class="govuk-service-navigation__link">${service}</a>
            </span>
          </div>
        </div>
      </section>
    </header>
    <div class="govuk-width-container">
      <div class="govuk-phase-banner">
        <p class="govuk-phase-banner__content">
          <strong class="govuk-tag govuk-phase-banner__content__tag">${phaseTag}</strong>
          <span class="govuk-phase-banner__text">${phaseText}</span>
        </p>
      </div>
      <main class="govuk-main-wrapper" id="main-content">
        <div class="govuk-notification-banner app-demo-banner" role="region" aria-labelledby="app-demo-banner-title" data-module="govuk-notification-banner">
          <div class="govuk-notification-banner__header">
            <h2 class="govuk-notification-banner__title" id="app-demo-banner-title">${bannerTitle}</h2>
          </div>
          <div class="govuk-notification-banner__content">
            <p class="govuk-notification-banner__heading">${bannerText}</p>
          </div>
        </div>
`
}

function chromeBottom() {
  return `      </main>
    </div>
    <footer class="govuk-template__footer">
      <div class="govuk-width-container">
        <ul class="govuk-footer__inline-list">
          <li class="govuk-footer__inline-list-item"><a class="govuk-footer__link" href="/fees">Licence fees</a></li>
          <li class="govuk-footer__inline-list-item"><a class="govuk-footer__link" href="/components">Component catalogue</a></li>
        </ul>
      </div>
${footerHtml}
    </footer>
    <script type="module" src="/assets/govuk-frontend.min.js"></script>
    <script type="module">
      import { initAll } from "/assets/govuk-frontend.min.js"
      initAll()
    </script>
  </body>
</html>
`
}
