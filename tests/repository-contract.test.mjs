import assert from "node:assert/strict"
import { access, readFile, stat } from "node:fs/promises"
import test from "node:test"

const root = new URL("../", import.meta.url)
const manifest = JSON.parse(await readFile(new URL("manifest.json", root), "utf8"))
const readme = await readFile(new URL("README.md", root), "utf8")
const service = await readFile(new URL("Service.qml", root), "utf8")

const pluginId = "io.github.pbjorklund.secondary-black-background"
const repositoryUrl = "https://github.com/pbjorklund/omarchy-secondary-black-background.git"

test("manifest exposes one loadable service", async () => {
  assert.equal(manifest.schemaVersion, 1)
  assert.equal(manifest.id, pluginId)
  assert.deepEqual(manifest.kinds, ["service"])
  assert.equal(manifest.entryPoints.service, "Service.qml")
  await access(new URL(manifest.entryPoints.service, root))
})

test("service does not load files or start subprocesses", () => {
  assert.match(service, /OMARCHY_SECONDARY_BLACK_BACKGROUND_MAIN_MONITORS/)
  assert.match(service, /onScreensChanged/)
  assert.match(service, /startupRefreshAttempts < 20/)
  assert.doesNotMatch(service, /Quickshell\.Io|\bFileView\b|\bProcess\b|\bStdioCollector\b/)
})

test("repository includes marketplace documentation and preview", async () => {
  await Promise.all([
    access(new URL("LICENSE", root)),
    access(new URL("preview.png", root))
  ])

  assert.match(readme, new RegExp(`omarchy plugin add ${repositoryUrl.replaceAll(".", "\\.")} --enable`))
  assert.match(readme, new RegExp(`omarchy plugin remove ${pluginId.replaceAll(".", "\\.")} --yes`))
})

test("marketplace preview is a bounded 1600 by 900 PNG", async () => {
  const previewUrl = new URL("preview.png", root)
  const [preview, metadata] = await Promise.all([readFile(previewUrl), stat(previewUrl)])

  assert.deepEqual(Array.from(preview.subarray(0, 8)), [137, 80, 78, 71, 13, 10, 26, 10])
  assert.equal(preview.readUInt32BE(16), 1600)
  assert.equal(preview.readUInt32BE(20), 900)
  assert.ok(metadata.size < 5 * 1024 * 1024)
})

test("preview source is self-contained", async () => {
  const source = await readFile(new URL("assets/preview.html", root), "utf8")

  assert.doesNotMatch(source, /<(script|iframe|object|embed)\b/i)
  assert.doesNotMatch(source, /(?:src|href)=["'](?:https?:)?\/\//i)
})
