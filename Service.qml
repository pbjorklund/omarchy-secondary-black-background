import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Item {
  id: root

  readonly property string configPath: Quickshell.env("HOME") + "/.config/omarchy/secondary-black-background.json"
  property var preferredMainMonitors: []
  property string mainOutput: ""

  function applyConfig(raw) {
    try {
      const config = JSON.parse(raw)
      preferredMainMonitors = Array.isArray(config.mainMonitors)
        ? config.mainMonitors.map(value => String(value).trim()).filter(Boolean)
        : []
    } catch (error) {
      preferredMainMonitors = []
    }
    refreshMonitors()
  }

  function refreshMonitors() {
    if (!monitorProc.running) monitorProc.running = true
  }

  function selectMainOutput(raw) {
    try {
      const monitors = JSON.parse(raw)
      let main = null

      for (const description of preferredMainMonitors) {
        main = monitors.find(monitor => String(monitor.description || "").includes(description))
        if (main) break
      }

      if (!main) main = monitors.find(monitor => monitor.focused)
      if (!main && monitors.length > 0) main = monitors[0]
      mainOutput = main ? String(main.name || "") : ""
    } catch (error) {
      console.warn("Could not identify the main monitor:", error)
      mainOutput = ""
    }
  }

  FileView {
    id: configFile
    path: root.configPath
    watchChanges: true
    printErrors: false
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("")
    onFileChanged: reload()
  }

  Process {
    id: monitorProc
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: root.selectMainOutput(String(text || ""))
    }
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      root.refreshMonitors()
    }
  }

  Component.onCompleted: refreshMonitors()

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData

      screen: modelData
      visible: root.mainOutput !== "" && modelData.name !== root.mainOutput
      anchors { top: true; bottom: true; left: true; right: true }
      color: "#000000"
      mask: Region {}

      WlrLayershell.namespace: "secondary-black-background"
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
    }
  }
}
