import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Wayland
import ".."
import "../utils" as Utils

import "../smallicons/" as Smallicons

PanelWindow {
    id: root

    property int menuWidth: 0
    property int popupWidth: 600
    property int screenHeight: 0
    property var currentApps: Utils.AppSearch.fuzzyQuery("A")
    property var closeCallback: function () {}
    property int currentPopup: Config.SystemPopup.AppLauncher
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore //Ignore
    WlrLayershell.namespace: "diinki_celestialantiquity:bars"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    property color glassColor: Config.colors.appLauncherBackground
    color: Config.settings.appLauncherBackground ? Qt.rgba(glassColor.r, glassColor.g, glassColor.b, 0.3) : "transparent"

    visible: currentPopup == Config.SystemPopup.AppLauncher ? true : false
    //visible: true
    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.closeCallback();
        }
    }

    Rectangle {
        id: frame
        opacity: 1
        //anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        implicitHeight: 350
        implicitWidth: 600
        color: "transparent"
        layer.enabled: true

        Rectangle {
            id: startMenuFrame
            anchors.fill: parent
            property color glassColor: Config.colors.glassTintColor
            color: Qt.rgba(glassColor.r, glassColor.g, glassColor.b, 0.2)
            border.width: 1
            border.color: Config.colors.outline

            radius: Config.settings.defaultWindowRadius
            Item {
                id: content
                anchors.fill: startMenuFrame
                anchors.margins: 10
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        implicitHeight: 48
                        color: Config.colors.base
                        border.width: 0
                        radius: 6
                        clip: true
                        Smallicons.BackgroundPatternOne {
                            lineColor: Config.colors.patternLineColor
                            x: -320
                            y: -10
                            property real scale: 0.36
                            width: implicitWidth * scale
                            height: implicitHeight * scale
                        }
                        TextField {
                            id: searchInput
                            width: parent.width
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 17
                            font.family: fontRecia.name
                            font.weight: 700
                            color: Config.colors.accent
                            selectionColor: Config.colors.textLight

                            padding: 2
                            selectByMouse: true
                            cursorVisible: false
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            focus: true

                            background: Rectangle {
                                color: "transparent"
                            }

                            Keys.onEscapePressed: {
                                root.closeCallback();
                            }

                            Component.onCompleted: {
                                searchInput.forceActiveFocus();
                            }
                            onAccepted: {
                                if (root.currentApps.length >= 1) {
                                    root.currentApps[0].execute();
                                    root.closeCallback();
                                }
                            }
                            onTextChanged: {
                                root.currentApps = Utils.AppSearch.fuzzyQuery(searchInput.text);
                                //console.log(Utils.AppSearch.fuzzyQuery(searchInput.text)[0].name);
                            }
                        }
                        Rectangle {
                            implicitHeight: parent.height
                            implicitWidth: parent.height
                            topLeftRadius: 6
                            bottomLeftRadius: 6
                            Layout.alignment: Qt.AlignLeft
                            color: Config.colors.base
                            border.width: 0
                            Text {
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                anchors.fill: parent
                                font.family: iconFont.name
                                color: Config.colors.accent
                                font.pixelSize: 24
                                text: "\ue8b6"
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: parent.width
                        Layout.fillHeight: true
                        Layout.topMargin: 3
                        color: Config.colors.base
                        border.width: 0
                        radius: 6
                        clip: true
                        Smallicons.BackgroundPatternOne {
                            lineColor: Config.colors.patternLineColor
                            x: -650
                            y: -30
                            property real scale: 0.46
                            width: implicitWidth * scale
                            height: implicitHeight * scale
                        }
                        ListView {
                            id: appsView
                            model: root.currentApps

                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.bottomMargin: 1

                            flickableDirection: Flickable.VerticalFlick
                            boundsBehavior: Flickable.DragOverBounds
                            maximumFlickVelocity: 3500
                            clip: true
                            // changed spacing to ignore results that have no valid icon image
                            spacing: (modelData.icon && Utils.AppSearch.getIcon(modelData.icon) !== "") ? 9 : 0
                            delegate: Item {
                                width: parent.width
                				// changed visibility to hide results that have no valid icon image
                                visible: (modelData.icon && Utils.AppSearch.getIcon(modelData.icon) !== "")
                                height: (modelData.icon && Utils.AppSearch.getIcon(modelData.icon) !== "") ? 48 : 0
                                Rectangle {
                                    width: parent.width
                                    // changed height rules to ignore results that have no valid icon image
                                    height: (modelData.icon && Utils.AppSearch.getIcon(modelData.icon) !== "") ? 48 : 0
                                    opacity: 1
                                    anchors.fill: parent
                                    color: Config.colors.base
                                    radius: 4
                                    border.width: 1
                                    border.color: mouse.hovered ? Config.colors.accent : Config.colors.highlight
                                    Behavior on border.color {
                                        ColorAnimation {
                                            duration: 64
                                        }
                                    }
                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 64
                                        }
                                    }
                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: 0
                                        property var iconPath: Utils.AppSearch.getIcon(modelData.icon)
                                        Image {
                                            Layout.leftMargin: 8
                                            asynchronous: true
                                            Layout.maximumWidth: 38
                                            Layout.maximumHeight: 38
                                            antialiasing: true
                                            source: parent.iconPath
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            Layout.leftMargin: 12
                                            Layout.alignment: Qt.AlignLeft
                                            color: mouse.hovered ? Config.colors.accent : Config.colors.textLight
                                            text: modelData.name
                                            font.family: fontQuilon.name
                                            font.weight: 200
                                            font.pixelSize: 15
                                        }
                                    }
                                    MouseArea {
                                        anchors.fill: parent

                                        HoverHandler {
                                            id: mouse
                                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                        onReleased: {
                                            modelData.execute();
                                            root.closeCallback();
                                        }
                                    }

                                    Rectangle {
                                        height: parent.height
                                        width: parent.height
                                        anchors.right: parent.right
                                        //color: Config.favoriteApps[modelData.name] == null ? "white" : "yellow"
                                        color: "transparent"
                                        z: 100

                                        Text {
                                            anchors.fill: parent
                                            font.family: iconFont.name
                                            color: Config.favoriteApps[modelData.name] != null || favoritesHovered.hovered ? Config.colors.accent : Config.colors.text
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            font.weight: 700
                                            font.pixelSize: 30
                                            text: ""
                                        }

                                        MouseArea {

                                            anchors.fill: parent
                                            HoverHandler {
                                                id: favoritesHovered
                                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                                cursorShape: Qt.PointingHandCursor
                                            }
                                            onReleased: {
                                                Config.toggleFavoriteApp(modelData.name, modelData.command, modelData.icon);
                                            }
                                        }
                                    }
                                }
                            }

                            ScrollIndicator.horizontal: ScrollIndicator {
                                active: appsView.moving
                            }
                        }
                    }
                }
            }
        }
    }
}
