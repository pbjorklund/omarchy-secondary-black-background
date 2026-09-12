import assert from "node:assert/strict"
import { readFile } from "node:fs/promises"
import test from "node:test"
import vm from "node:vm"

const source = await readFile(new URL("../MonitorSelection.js", import.meta.url), "utf8")
const context = vm.createContext({})
vm.runInContext(source, context, { filename: "MonitorSelection.js" })

const { parsePreferences, selectMainOutput } = context

test("parsePreferences keeps trimmed non-empty values", () => {
  const result = parsePreferences(" AW2725Q ,, DP-3 ")

  assert.deepEqual(Array.from(result), ["AW2725Q", "DP-3"])
})

test("parsePreferences accepts an empty preference list", () => {
  assert.deepEqual(Array.from(parsePreferences("")), [])
  assert.deepEqual(Array.from(parsePreferences("  ,  ")), [])
  assert.deepEqual(Array.from(parsePreferences(null)), [])
})

test("parsePreferences rejects oversized input", () => {
  assert.deepEqual(Array.from(parsePreferences("x".repeat(4097))), [])
})

test("parsePreferences bounds preference count and length", () => {
  const tooMany = Array(17).fill("DP-1").join(",")
  const tooLong = "x".repeat(257)

  assert.deepEqual(Array.from(parsePreferences(tooMany)), [])
  assert.deepEqual(Array.from(parsePreferences(tooLong)), [])
})

test("selectMainOutput honors configured preference order", () => {
  const monitors = [
    { name: "DP-2", description: "Acer XV240Y" },
    { name: "DP-3", description: "Dell AW2725Q" }
  ]

  assert.equal(selectMainOutput(monitors, ["AW2725Q", "Acer"], "DP-2"), "DP-3")
})

test("selectMainOutput accepts an exact output name", () => {
  const monitors = [
    { name: "DP-2", description: "Acer XV240Y" },
    { name: "DP-3", description: "Dell AW2725Q" }
  ]

  assert.equal(selectMainOutput(monitors, ["DP-3"], "DP-2"), "DP-3")
})

test("selectMainOutput falls back to the focused display", () => {
  const monitors = [
    { name: "DP-2", description: "Acer XV240Y" },
    { name: "DP-3", description: "Dell AW2725Q" }
  ]

  assert.equal(selectMainOutput(monitors, ["missing"], "DP-3"), "DP-3")
})

test("selectMainOutput falls back to the first valid display", () => {
  const monitors = [
    null,
    { name: "", description: "Invalid" },
    { name: "DP-2", description: "Acer XV240Y" }
  ]

  assert.equal(selectMainOutput(monitors, [], "missing"), "DP-2")
})

test("selectMainOutput fails open for invalid monitor data", () => {
  assert.equal(selectMainOutput(null, []), "")
  assert.equal(selectMainOutput({}, []), "")
  assert.equal(selectMainOutput([], []), "")
})
