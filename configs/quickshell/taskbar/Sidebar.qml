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
import "../sidebarPopups/" as Popups
import ".."

Scope {
    Variants {
        model: Quickshell.screens
        Item {
            id: root
            required property var modelData
            property bool sidebarEnabled: Config.radialBarSetting(modelData.name, "enableSidebar")
            property bool raiseOnHover: Config.radialBarSetting(modelData.name, "raiseOnHover")

            // This is a "tap outside of popup to clise it" functionality. Might abstract it later.
            PanelWindow {
                id: closerPanel
                screen: root.modelData
                WlrLayershell.layer: WlrLayer.Top
                visible: root.sidebarEnabled && (radialTaskbar.isOpen || radialTaskbar.currentPopup != Config.SidebarPopup.None)
                //WlrLayershell.layer: WlrLayer.Bottom
                exclusionMode: ExclusionMode.Ignore //Ignore
                color: Qt.rgba(0, 0, 0, 0)
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        radialTaskbar.closeAllPopups();
                    }
                }
            }
            PanelWindow {
                id: radialTaskbar
                screen: root.modelData
                visible: root.sidebarEnabled
                WlrLayershell.layer: isOpen || currentPopup != Config.SidebarPopup.None ? WlrLayer.Top : WlrLayer.Bottom

                //WlrLayershell.layer: WlrLayer.Bottom
                exclusionMode: ExclusionMode.Ignore //Ignore
                WlrLayershell.namespace: "diinki_celestialantiquity:bars"

                property int currentPopup: Config.SidebarPopup.None

                property bool isOpen: false
                function refreshState(workspaceId) {
                    Hyprland.dispatch(`workspace ` + workspaceId);
                }
                function closeAllPopups() {
                    currentPopup = Config.SidebarPopup.None;

                    radialTaskbar.isOpen = false;
                }
                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: false
                }
                implicitWidth: 115
                color: Qt.rgba(0, 0, 0, 0)

                /*
                // Close the popup when clicking outside of the window.

                */
                Item {
                    id: radialBarCurve
                    anchors.fill: parent
                    // This is kind of ugly, prolly a better way to get this kind of
                    // dynamic scale depending on screen size, but width of the screen
                    // divided by 3 is a reasonable width in my opinion.
                    property point pointA: Qt.point(0, parent.height - parent.height / 1.38)
                    property point pointB: Qt.point(0, parent.height / 1.38)
                    property real curvature: 175

                    property point innerPointA: Qt.point(0, parent.height - parent.height / 1.57)
                    property point innerPointB: Qt.point(0, parent.height / 1.57)

                    function controlPoint(a, b, curve) {
                        var midX = (a.x + b.x) / 2;
                        var midY = (a.y + b.y) / 2;
                        return Qt.point(midX + curve, midY);
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

                            var cp = parent.controlPoint(parent.innerPointA, parent.innerPointB, 70);

                            ctx.beginPath();
                            ctx.moveTo(parent.innerPointA.x, parent.innerPointA.y);
                            ctx.quadraticCurveTo(cp.x, cp.y, parent.innerPointB.x, parent.innerPointB.y);
                            ctx.lineWidth = 1;
                            ctx.fillStyle = Qt.rgba(0, 0, 0, 0.2);
                            ctx.strokeStyle = Config.colors.cbodyStroke;
                            ctx.stroke();
                            ctx.fill();
                        }
                    }
                    // Sun: PowerMenu
                    Rectangle {
                        id: sunButton
                        width: 50
                        height: 50
                        property real t: 1 - 0.0
                        property point p: parent.pointOnCurve(t, parent.pointA, parent.pointB)

                        x: p.x - width / 2
                        y: p.y - height / 2

                        color: "transparent"
                        RectangularShadow {
                            anchors.centerIn: parent
                            width: 70
                            height: 70
                            radius: width / 2
                            blur: 32
                        }

                        Popups.PowerMenu {
                            id: powerMenu
                            anchorWindow: radialTaskbar
                            buttonItem: sunButton
                            positionY: sunButton.p.y - height
                            positionX: sunButton.p.x + sunImage.width / 2
                            popupState: radialTaskbar.currentPopup
                        }
                        Smallicons.StarMoodRelaxed {
                            id: sunImage
                            backgroundColor: Config.colors.cbodyPowerMenu
                            lineColor: Config.colors.cbodyStroke
                            width: 170
                            height: 170
                            anchors.centerIn: parent
                            transform: [
                                Rotation {
                                    id: rotation
                                    origin.x: sunImage.width / 2
                                    origin.y: sunImage.height / 2
                                    angle: 0
                                }
                            ]
                            SequentialAnimation {
                                id: wiggle
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation {
                                    target: rotation
                                    property: "angle"
                                    to: -10
                                    duration: 4400
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: rotation
                                    property: "angle"
                                    to: 10
                                    duration: 4400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: sunImage

                            onClicked: {
                                radialTaskbar.currentPopup = radialTaskbar.currentPopup == Config.SidebarPopup.PowerMenu ? Config.SidebarPopup.None : Config.SidebarPopup.PowerMenu;
                            }
                            HoverHandler {
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    // Mercury: favorite apps
                    Rectangle {
                        id: mercuryButton
                        width: 50
                        height: 50

                        property real t: 1 - 0.24
                        property point p: parent.pointOnCurve(t, parent.pointA, parent.pointB)

                        x: p.x - width / 2
                        y: p.y - height / 2

                        color: "transparent"
                        Popups.FavoriteAppsMenu {
                            id: favoriteAppsMenu
                            anchorWindow: radialTaskbar
                            positionY: mercuryButton.p.y - height
                            positionX: mercuryButton.p.x + mercuryButton.width / 0.7
                            closeCallback: radialTaskbar.closeAllPopups
                            popupState: radialTaskbar.currentPopup
                        }
                        RectangularShadow {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: width / 2
                            blur: 16
                        }

                        Smallicons.CbodyMoodAgitated {
                            id: mercuryImage
                            width: 85
                            height: 85
                            anchors.centerIn: parent
                            backgroundColor: Config.colors.cbodyFavoriteApps
                            lineColor: Config.colors.cbodyStroke
                            transform: [
                                Rotation {
                                    id: mercuryRotation
                                    origin.x: mercuryImage.width / 2
                                    origin.y: mercuryImage.height / 2
                                    angle: 0
                                }
                            ]
                            SequentialAnimation {
                                id: wiggleMercury
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation {
                                    target: mercuryRotation
                                    property: "angle"
                                    to: -10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: mercuryRotation
                                    property: "angle"
                                    to: 10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: mercuryButton

                            onClicked: {
                                radialTaskbar.currentPopup = radialTaskbar.currentPopup == Config.SidebarPopup.FavoriteAppsMenu ? Config.SidebarPopup.None : Config.SidebarPopup.FavoriteAppsMenu;
                            }
                            HoverHandler {
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    // Venus: themes
                    Rectangle {
                        id: venusButton
                        width: 50
                        height: 50

                        property real t: 1 - 0.5
                        property point p: parent.pointOnCurve(t, parent.pointA, parent.pointB)

                        x: p.x - width / 2
                        y: p.y - height / 2

                        color: "transparent"

                        Popups.ThemingMenu {
                            id: themingMenu
                            anchorWindow: radialTaskbar
                            positionY: venusButton.p.y - height
                            positionX: venusButton.p.x + venusButton.width / 2

                            popupState: radialTaskbar.currentPopup
                        }
                        RectangularShadow {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: width / 2
                            blur: 16
                        }

                        Smallicons.CbodyMoodContent {
                            id: venusImage

                            lineColor: Config.colors.cbodyStroke
                            backgroundColor: Config.colors.cbodyThemingMenu
                            width: 85
                            height: 85
                            anchors.centerIn: parent
                            transform: [
                                Rotation {
                                    id: venusRotation
                                    origin.x: venusImage.width / 2
                                    origin.y: venusImage.height / 2
                                    angle: 0
                                }
                            ]
                            SequentialAnimation {
                                id: wiggleVenus
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation {
                                    target: venusRotation
                                    property: "angle"
                                    to: -10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: venusRotation
                                    property: "angle"
                                    to: 10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: venusButton

                            onClicked: {
                                radialTaskbar.currentPopup = radialTaskbar.currentPopup == Config.SidebarPopup.ThemingMenu ? Config.SidebarPopup.None : Config.SidebarPopup.ThemingMenu;
                            }
                            HoverHandler {
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    // Earth: Menu
                    Rectangle {
                        id: earthButton
                        width: 50
                        height: 50

                        property real t: 1 - 0.80
                        property point p: parent.pointOnCurve(t, parent.pointA, parent.pointB)

                        x: p.x - width / 2
                        y: p.y - height / 2

                        color: "transparent"
                        Popups.MainMenu {
                            id: mainMenu
                            anchorWindow: radialTaskbar
                            positionY: earthButton.y - height
                            positionX: earthButton.p.x + earthButton.width / 2
                            popupState: radialTaskbar.currentPopup
                            closeCallback: radialTaskbar.closeAllPopups
                        }
                        RectangularShadow {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            radius: width / 2
                            blur: 16
                        }

                        Smallicons.CbodyMoodRelaxed {
                            id: earthImage

                            lineColor: Config.colors.cbodyStroke
                            backgroundColor: Config.colors.cbodyMainMenu
                            width: 85
                            height: 85
                            anchors.centerIn: parent
                            transform: [
                                Rotation {
                                    id: earthRotation
                                    origin.x: earthImage.width / 2
                                    origin.y: earthImage.height / 2
                                    angle: 0
                                }
                            ]
                            SequentialAnimation {
                                id: wiggleEarth
                                running: true
                                loops: Animation.Infinite
                                NumberAnimation {
                                    target: earthRotation
                                    property: "angle"
                                    to: -10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                                NumberAnimation {
                                    target: earthRotation
                                    property: "angle"
                                    to: 10
                                    duration: 3400
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: earthButton

                            onClicked: {
                                radialTaskbar.isOpen = true;
                                radialTaskbar.currentPopup = radialTaskbar.currentPopup == Config.SidebarPopup.MainMenu ? Config.SidebarPopup.None : Config.SidebarPopup.MainMenu;
                            }
                            HoverHandler {
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
                // Mouse areas in order to move the ui to the front or back depending on
                // mouse enter.
                MouseArea {
                    //anchors.top: parent.top
                    //anchors.bottom: parent.bottom
                    //anchors.top: parent.top
                    anchors.left: parent.left
                    //anchors.centerIn: parent
                    width: 8
                    height: parent.height / 1.7
                    y: (parent.height - height) / 2

                    hoverEnabled: true
                    onEntered: {
                        if (root.raiseOnHover) {
                            radialTaskbar.isOpen = true;
                        }
                    }
                }
                MouseArea {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    height: 8
                    width: 10
                    hoverEnabled: true
                    onEntered: {
                        if (radialTaskbar.currentPopup == Config.SidebarPopup.None) {
                            radialTaskbar.isOpen = false;
                        }
                    }
                }
            }
            // Lets you raise/lower the sidebar with a hyprland keybind, see the
            // toggleBars command in hyprland.lua.
            Scope {
                id: sidebarIpc
                property string screenName: radialTaskbar.screen.name
                IpcHandler {
                    target: "sidebar_" + sidebarIpc.screenName
                    function toggle() {
                        if (radialTaskbar.isOpen || radialTaskbar.currentPopup != Config.SidebarPopup.None) {
                            radialTaskbar.closeAllPopups();
                        } else {
                            radialTaskbar.isOpen = true;
                        }
                    }
                }
            }
        }
    }
}
