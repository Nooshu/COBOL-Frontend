import { spawn } from "node:child_process"
import fs from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const componentsDir = path.join(
  root,
  "node_modules",
  "govuk-frontend",
  "dist",
  "govuk",
  "components",
)
const baseUrl = process.env.BASE_URL ?? "http://127.0.0.1:8080"
const color = process.stdout.isTTY && !process.env.NO_COLOR
const green = color ? "\x1b[32m" : ""
const red = color ? "\x1b[31m" : ""
const dim = color ? "\x1b[2m" : ""
const reset = color ? "\x1b[0m" : ""

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

function fixturePaths(name, fixtures) {
  const used = new Set()
  return fixtures.map((fixture) => {
    let fileName = slug(fixture.name)
    let suffix = 2
    while (used.has(fileName)) {
      fileName = `${slug(fixture.name)}-${suffix}`
      suffix += 1
    }
    used.add(fileName)
    return {
      name: fixture.name,
      html: fixture.html,
      href: `/components/${name}/${fileName}.html`,
    }
  })
}

function components() {
  return fs
    .readdirSync(componentsDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .filter((name) => fs.existsSync(path.join(componentsDir, name, "fixtures.json")))
    .sort()
    .map((name) => {
      const document = JSON.parse(
        fs.readFileSync(path.join(componentsDir, name, "fixtures.json"), "utf8"),
      )
      return {
        name,
        label: label(name),
        fixtures: fixturePaths(name, document.fixtures),
      }
    })
}

async function serverReachable() {
  try {
    await fetch(baseUrl, { signal: AbortSignal.timeout(2000) })
    return true
  } catch {
    return false
  }
}

function startServer() {
  return new Promise((resolve, reject) => {
    const child = spawn("docker", ["compose", "up", "-d", "--build"], {
      cwd: root,
      stdio: "inherit",
    })
    child.on("error", reject)
    child.on("exit", (code) => {
      if (code === 0) {
        resolve()
      } else {
        reject(new Error(`docker compose up --build exited ${code}`))
      }
    })
  })
}

async function ensureServer() {
  if (await serverReachable()) {
    return
  }
  console.log("Starting the server…")
  await startServer()
  const deadline = Date.now() + 30_000
  while (Date.now() < deadline) {
    if (await serverReachable()) {
      console.log(baseUrl)
      return
    }
    await new Promise((resolve) => {
      setTimeout(resolve, 300)
    })
  }
  throw new Error(`The server did not start at ${baseUrl}`)
}

async function checkFixture(fixture) {
  let response
  try {
    response = await fetch(`${baseUrl}${fixture.href}`)
  } catch (error) {
    const reason = error instanceof Error ? error.message : String(error)
    return `could not reach ${baseUrl} (${reason})`
  }
  if (!response.ok) {
    return `${fixture.href} returned ${response.status}`
  }
  const body = await response.text()
  if (!body.includes(fixture.html)) {
    return `${fixture.name} HTML was not in ${fixture.href}`
  }
  return ""
}

try {
  await ensureServer()
} catch (error) {
  const reason = error instanceof Error ? error.message : String(error)
  console.error(`${red}${reason}${reset}`)
  process.exit(1)
}

const list = components()
const width = Math.max(...list.map((component) => component.label.length))
let failedComponents = 0
let passedFixtures = 0

for (const component of list) {
  const failures = []
  for (const fixture of component.fixtures) {
    const failure = await checkFixture(fixture)
    if (failure) {
      failures.push(failure)
      if (failure.startsWith("could not reach")) {
        console.error(`${red}The server at ${baseUrl} stopped responding.${reset}`)
        process.exit(1)
      }
    }
  }
  if (failures.length > 0) {
    failedComponents += 1
    console.log(`${red}✗${reset} ${component.label}`)
    for (const failure of failures) {
      console.log(`  ${failure}`)
    }
  } else {
    passedFixtures += component.fixtures.length
    const count = `${component.fixtures.length} fixtures`
    console.log(
      `${green}✓${reset} ${component.label.padEnd(width)}  ${dim}${count} passed${reset}`,
    )
  }
}

if (failedComponents > 0) {
  console.error(
    `${red}${failedComponents} of ${list.length} components failed${reset}`,
  )
  process.exit(1)
}

console.log(
  `${green}${list.length} components passed${reset} ${dim}(${passedFixtures} fixtures)${reset}`,
)
