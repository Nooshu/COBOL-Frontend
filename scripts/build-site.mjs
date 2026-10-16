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

const headerHtml = fixtureHtml("header", "default")
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
    <link rel="icon" sizes="48x48" href="/assets/images/favicon.ico">
    <link rel="icon" sizes="any" href="/assets/images/favicon.svg" type="image/svg+xml">
    <link rel="mask-icon" href="/assets/images/govuk-icon-mask.svg" color="#1d70b8">
    <link rel="apple-touch-icon" href="/assets/images/govuk-icon-180.png">
    <link rel="manifest" href="/assets/manifest.json">
    <link rel="stylesheet" href="/assets/govuk-frontend.min.css">
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
              <a href="/" class="govuk-service-navigation__link">GOV.UK Frontend fixtures</a>
            </span>
          </div>
        </div>
      </section>
    </header>
    <div class="govuk-width-container">
      <main class="govuk-main-wrapper" id="main-content">
${content}
      </main>
    </div>
    <footer class="govuk-template__footer">
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

fs.writeFileSync(path.join(siteDir, "index.html"), index)
console.log(`Wrote ${components.length} components to ${siteDir}`)
