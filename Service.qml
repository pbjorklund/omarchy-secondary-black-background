import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "MonitorSelection.js" as MonitorSelection

Item {
  id: root

  readonly property string configPath: Quickshell.env("HOME") + "/.config/omarchy/secondary-black-background.json"
  property var preferredMainMonitors: []
  property string mainOutput: ""

  function applyConfig(raw) {
    preferredMainMonitors = MonitorSelection.parsePreferences(raw)
    refreshMainOutput()
  }

  function refreshMainOutput() {
    const monitors = Hyprland.monitors ? Hyprland.monitors.values : []
    const focused = Hyprland.focusedMonitor
    const focusedOutput = focused ? String(focused.name || "") : ""
    mainOutput = MonitorSelection.selectMainOutput(monitors, preferredMainMonitors, focusedOutput)
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

  Connections {
    target: Hyprland.monitors
    function onValuesChanged() {
      root.refreshMainOutput()
    }
  }

  Connections {
    target: Hyprland
    function onFocusedMonitorChanged() {
      if (root.mainOutput === "") root.refreshMainOutput()
    }
  }

  Component.onCompleted: refreshMainOutput()

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
