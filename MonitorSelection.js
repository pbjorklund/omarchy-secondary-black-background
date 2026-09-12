function parsePreferences(raw) {
  try {
    const config = JSON.parse(String(raw || ""))
    if (!config || Array.isArray(config) || !Array.isArray(config.mainMonitors)) return []

    return config.mainMonitors
      .filter(value => typeof value === "string")
      .map(value => value.trim())
      .filter(value => value.length > 0)
  } catch (error) {
    return []
  }
}

function selectMainOutput(monitors, preferences, focusedOutput) {
  if (!Array.isArray(monitors)) return ""

  const validMonitors = monitors.filter(monitor =>
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
