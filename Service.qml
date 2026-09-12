import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import "MonitorSelection.js" as MonitorSelection

Item {
  id: root

  readonly property var preferredMainMonitors: MonitorSelection.parsePreferences(
    Quickshell.env("OMARCHY_SECONDARY_BLACK_BACKGROUND_MAIN_MONITORS")
  )
  property string mainOutput: ""
  property int startupRefreshAttempts: 0

  function refreshMainOutput() {
    const monitors = Hyprland.monitors ? Hyprland.monitors.values : []
    const focused = Hyprland.focusedMonitor
    const focusedOutput = focused ? String(focused.name || "") : ""
    mainOutput = MonitorSelection.selectMainOutput(monitors, preferredMainMonitors, focusedOutput)
  }

  Connections {
    target: Quickshell
    function onScreensChanged() {
      root.refreshMainOutput()
    }
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

  Timer {
    interval: 100
    repeat: true
    running: root.mainOutput === "" && root.startupRefreshAttempts < 20
    onTriggered: {
      root.startupRefreshAttempts += 1
      root.refreshMainOutput()
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
