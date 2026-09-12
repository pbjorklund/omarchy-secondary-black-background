function parsePreferences(raw) {
  if (typeof raw !== "string" || raw.length > 4096) return []

  const values = raw.split(",")
  if (values.length > 16) return []

  const preferences = values
    .map(value => value.trim())
    .filter(value => value.length > 0)

  return preferences.some(value => value.length > 256) ? [] : preferences
}

function selectMainOutput(monitors, preferences, focusedOutput) {
  if (!monitors || !Number.isInteger(monitors.length) || monitors.length < 0 || monitors.length > 64) return ""

  const validMonitors = Array.from(monitors).filter(monitor =>
    monitor
    && typeof monitor.name === "string"
    && monitor.name.trim().length > 0
  )
  if (validMonitors.length === 0) return ""

  const validPreferences = Array.isArray(preferences) ? preferences : []
  for (const preference of validPreferences) {
    if (typeof preference !== "string" || preference.length === 0) continue

    const match = validMonitors.find(monitor =>
      monitor.name === preference
      || String(monitor.description || "").includes(preference)
    )
    if (match) return match.name
  }

  const focused = validMonitors.find(monitor => monitor.name === focusedOutput)
  return focused ? focused.name : validMonitors[0].name
}
