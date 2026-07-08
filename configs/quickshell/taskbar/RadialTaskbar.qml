import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import Qt5Compat.GraphicalEffects
import "../smallicons/" as Smallicons
import "../utils/" as Utils
import "../popups" as Popups
import ".."

Scope {
    Variants {
        model: Quickshell.screens
        Item {
            id: root
            required property var modelData
            property bool bottomBarEnabled: Config.radialBarSetting(modelData.name, "enableBottomBar")
            property bool raiseOnHover: Config.radialBarSetting(modelData.name, "raiseOnHover")
            PanelWindow {
                id: radialTaskbar
                screen: root.modelData
                visible: root.bottomBarEnabled
                WlrLayershell.layer: isOpen ? WlrLayer.Top : WlrLayer.Bottom
                exclusionMode: ExclusionMode.Ignore //Ignore
                WlrLayershell.namespace: "diinki_celestialantiquity:bars"

                property bool isOpen: false
                function refreshState(workspaceId) {
                    Hyprland.dispatch(`hl.dsp.focus({workspace = "${workspaceId}"})`);
                }
                anchors {
                    bottom: true
                    left: true
                    right: true
                }
                implicitHeight: 150
                color: Qt.rgba(0, 0, 0, 0.0)

                // A very subtle shadow, but i think it adds a lot.
                // I am aware that the resolution math looks like black
                // magic, I will probably fix this shadow eventually.
                RectangularShadow {
                    anchors.centerIn: parent
                    width: parent.width * 1.5
                    height: parent.width * 1.5
                    color: Qt.rgba(0, 0, 0, 1)
                    blur: 120
                    spread: 10
                    radius: width / 2
                    offset.y: parent.width / 1.3
                    visible: true
                }
                Item {
                    id: radialBarCurve
                    anchors.fill: parent

                    // Mouse areas in order to move the ui to the front or back depending on
                    // mouse enter.
                    MouseArea {
                        anchors.top: parent.top
                        height: 8
                        width: parent.width
                        hoverEnabled: true
                        onEntered: {
                            radialTaskbar.isOpen = false;
                        }
                    }
                    MouseArea {
                        anchors.bottom: parent.bottom
                        height: 8
                        width: parent.width
                        hoverEnabled: true
                        onEntered: {
                            if (root.raiseOnHover) {
                                radialTaskbar.isOpen = true;
                            }
                        }
                    }

                    // This is kind of ugly, prolly a better way to get this kind of
                    // dynamic scale depending on screen size, but width of the screen
                    // divided by 3 is a reasonable width in my opinion.
                    property int arcWidth: parent.width / 3
                    property point pointA: Qt.point(parent.width / 2 - arcWidth, parent.height)
                    property point pointB: Qt.point(parent.width / 2 + arcWidth, parent.height)
                    property real curvature: -170

                    property point innerPointA: Qt.point(parent.width / 2 - arcWidth / 1.5, parent.height)
                    property point innerPointB: Qt.point(parent.width / 2 + arcWidth / 1.5, parent.height)

                    function controlPoint(a, b, curve) {
                        var midX = (a.x + b.x) / 2;
                        var midY = (a.y + b.y) / 2;
                        return Qt.point(midX, midY + curve);
                    }
                    function pointOnCurve(t, a, b) {
                        var cp = controlPoint(a, b, curvature);
                        var x = Math.pow(1 - t, 2) * pointA.x + 2 * (1 - t) * t * cp.x + Math.pow(t, 2) * pointB.x;

                        var y = Math.pow(1 - t, 2) * pointA.y + 2 * (1 - t) * t * cp.y + Math.pow(t, 2) * pointB.y;

                        return Qt.point(x, y);
                    }

                    // Main curve
                    Canvas {
                        id: curveCanvas
                        anchors.fill: parent
                        property color glassColor: Config.colors.glassTintColor
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var cp = parent.controlPoint(parent.pointA, parent.pointB, parent.curvature);
                            ctx.beginPath();
                            ctx.moveTo(parent.pointA.x, parent.pointA.y);
                            ctx.quadraticCurveTo(cp.x, cp.y, parent.pointB.x, parent.pointB.y);
                            ctx.closePath();
                            ctx.lineWidth = 1;
                            ctx.strokeStyle = Config.colors.cbodyStroke;
                            ctx.fillStyle = Qt.rgba(glassColor.r, glassColor.g, glassColor.b, 0.2);

                            ctx.fill();
                            ctx.stroke();
                        }
                    }
                    // Inner curve
                    Canvas {
                        id: innerCurveCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var cp = parent.controlPoint(parent.innerPointA, parent.innerPointB, -75);

                            ctx.beginPath();
                            ctx.moveTo(parent.innerPointA.x, parent.innerPointA.y);
                            ctx.quadraticCurveTo(cp.x, cp.y, parent.innerPointB.x, parent.innerPointB.y);
                            ctx.lineWidth = 1;
                            ctx.strokeStyle = Config.colors.cbodyStroke;
                            ctx.stroke();
                        }
                    }

                    property int buttonCount: 3
                    property var currentWorkspaces: Hyprland.workspaces.values.filter(w => w.monitor.name == radialTaskbar.screen.name)

                    // The workspace "bar"
                    Repeater {
                        id: workspaceRepeater
                        model: parent.currentWorkspaces

                        delegate: Rectangle {
                            id: workspaceButtonRect
                            property bool isActive: modelData.id == Hyprland.focusedWorkspace.id ? true : false
                            width: 26
                            height: 26
                            radius: width / 2
                            color: "transparent"
                            border.width: 0

                            property real t: 0 + Config.settings.bar.workspacePadding * index
                            property real offset: 0.13
                            property point p: radialBarCurve.pointOnCurve(t + offset, radialBarCurve.pointA, radialBarCurve.pointB)

                            x: p.x - width / 2
                            y: p.y - height / 2
                            RectangularShadow {
                                anchors.centerIn: parent
                                width: 17
                                height: 17
                                radius: width / 2
                                blur: 14
                            }
                            Button {
                                id: control
                                width: parent.width
                                height: parent.height
                                background: Rectangle {
                                    color: "transparent"
                                }
                                Smallicons.StarOutlineNoBase {
                                    id: btnImg
                                    width: 50
                                    height: 50
                                    //anchors.fill: parent
                                    anchors.centerIn: parent
                                    visible: true
                                    antialiasing: true
                                    lineColor: Config.colors.cbodyStroke

                                    transform: [
                                        Rotation {
                                            id: rotation
                                            origin.x: btnImg.width / 2
                                            origin.y: btnImg.height / 2
                                            angle: 0
                                        },
                                        Scale {
                                            origin.x: btnImg.width / 2
                                            origin.y: btnImg.height / 2
                                            xScale: btnImg.s
                                            yScale: btnImg.s
                                        }
                                    ]
                                    property real s: isActive ? 1 : 0
                                    SequentialAnimation {
                                        id: wiggle
                                        running: true
                                        loops: Animation.Infinite
                                        NumberAnimation {
                                            target: rotation
                                            property: "angle"
                                            to: -10
                                            duration: 2400
                                            easing.type: Easing.InOutQuad
                                        }
                                        NumberAnimation {
                                            target: rotation
                                            property: "angle"
                                            to: 10
                                            duration: 2400
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                    Behavior on s {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.InOutCubic
                                        }
                                    }
                                }
                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    anchors.centerIn: parent
                                    color: mouse.hovered ? Config.colors.cbodyBackgroundShadow : Config.colors.cbodyBackground
                                    border.color: Config.colors.cbodyStroke
                                    border.width: 1
                                    radius: width / 2
                                }
                                contentItem: Text {
                                    anchors.fill: parent
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.weight: isActive || mouse.hovered ? 700 : 600
                                    font.family: fontBoska.name
                                    width: 10
                                    height: 10
                                    font.pixelSize: 14
                                    color: Config.colors.text
                                    text: Utils.TextUtils.toRomanNumeral(modelData.id)
                                }
                                onPressed: event => {
                                    radialTaskbar.refreshState(modelData.id);
                                }
                                HoverHandler {
                                    id: mouse
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                    // System tray
                    property int otherButtonCount: 3
                    Repeater {
                        id: sysTray
                        model: SystemTray.items
                        delegate: Rectangle {
                            id: trayItem
                            width: 27
                            height: 27
                            radius: width / 2
                            border.width: 1
                            border.color: Config.colors.cbodyStroke
                            color: trayMouse.hovered ? Config.colors.cbodyBackgroundShadow : Config.colors.cbodyBackground
                            property SystemTrayItem item: modelData

                            property real t: 1 - 0.025 * index
                            property real offset: 0.1
                            property point p: parent.pointOnCurve(t - offset, parent.pointA, parent.pointB)

                            x: p.x - width / 2
                            y: p.y - height / 2
                            RectangularShadow {
                                anchors.centerIn: parent
                                width: 17
                                height: 17
                                radius: width / 2
                                blur: 14
                            }
                            function openMenu() {
                                menu.open();
                            }

                            QsMenuAnchor {
                                id: menu
                                menu: trayItem.item.menu
                                anchor.window: radialTaskbar

                                anchor.rect.x: trayItem.p.x + trayItem.width
                                anchor.rect.y: trayItem.p.y - trayItem.height - 10
                            }
                            property real iconOpacity: trayMouse.hovered || menu.visible ? 1 : 0
                            Behavior on iconOpacity {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.InOutCubic
                                }
                            }
                            IconImage {
                                id: trayIcon
                                source: trayItem.item.icon
                                anchors.centerIn: parent
                                width: 17
                                height: 17
                                opacity: trayItem.iconOpacity
                            }

                            Smallicons.CbodyMoodRelaxed {
                                width: 54
                                height: 54
                                anchors.centerIn: parent
                                backgroundColor: Config.colors.cbodyBackground
                                lineColor: Config.colors.cbodyStroke

                                transform: [
                                    Rotation {
                                        id: tRotation
                                        origin.x: trayItem.width
                                        origin.y: trayItem.height
                                        angle: -1
                                    }
                                ]

                                SequentialAnimation {
                                    id: tWiggle
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation {
                                        target: tRotation
                                        property: "angle"
                                        to: -16
                                        duration: 2399
                                        easing.type: Easing.InOutQuad
                                    }
                                    NumberAnimation {
                                        target: tRotation
                                        property: "angle"
                                        to: 14
                                        duration: 2399
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                            Loader {
                                anchors.fill: trayIcon
                                sourceComponent: MultiEffect {
                                    source: trayIcon
                                    blurEnabled: false
                                    shadowEnabled: false
                                    opacity: trayItem.iconOpacity
                                    contrast: 1

                                    colorization: 1
                                    colorizationColor: Config.colors.cbodyBackgroundShadow
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: event => {
                                    switch (event.button) {
                                    case Qt.LeftButton:
                                        if (trayItem.item.hasMenu) {
                                            trayItem.openMenu();
                                        }
                                        break;
                                    case Qt.RightButton:
                                        if (trayItem.item.hasMenu) {
                                            trayItem.openMenu();
                                        }
                                        break;
                                    }

                                    event.accepted = true;
                                }
                                HoverHandler {
                                    id: trayMouse
                                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }
                }
            }
            // Lets you raise/lower the bottom bar with a hyprland keybind, see the
            // toggleBars command in hyprland.lua.
            Scope {
                id: bottomBarIpc
                property string screenName: radialTaskbar.screen.name
                IpcHandler {
                    target: "bottombar_" + bottomBarIpc.screenName
                    function toggle() {
                        radialTaskbar.isOpen = !radialTaskbar.isOpen;
                    }
                }
            }
        }
    }
}
