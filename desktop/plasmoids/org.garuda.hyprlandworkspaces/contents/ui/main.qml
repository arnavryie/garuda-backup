import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.workspace.dbus as DBus

PlasmoidItem {
    id: root

    readonly property bool isVertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property int desktopCount: (vdInfo.numberOfDesktops > 0) ? vdInfo.numberOfDesktops : (vdInfo.desktopIds ? vdInfo.desktopIds.length : 5)
    readonly property int calculatedLength: Math.max(80, (desktopCount * 18) + 16)

    Layout.fillWidth: false
    Layout.fillHeight: false
    Layout.preferredWidth: isVertical ? 32 : calculatedLength
    Layout.minimumWidth: isVertical ? 24 : calculatedLength
    Layout.preferredHeight: isVertical ? calculatedLength : 28
    Layout.minimumHeight: isVertical ? calculatedLength : 24
    Layout.alignment: Qt.AlignVCenter

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    TaskManager.VirtualDesktopInfo {
        id: vdInfo
    }

    function activateDesktopByIndex(index) {
        if (typeof vdInfo.requestActivate === "function" && vdInfo.desktopIds && index >= 0 && index < vdInfo.desktopIds.length) {
            try {
                vdInfo.requestActivate(vdInfo.desktopIds[index]);
            } catch(e) {}
        }
        DBus.SessionBus.asyncCall({
            "service": "org.kde.KWin",
            "path": "/KWin",
            "iface": "org.kde.KWin",
            "member": "setCurrentDesktop",
            "arguments": [index + 1]
        });
    }

    function switchByDelta(delta) {
        DBus.SessionBus.asyncCall({
            "service": "org.kde.KWin",
            "path": "/KWin",
            "iface": "org.kde.KWin",
            "member": delta > 0 ? "nextDesktop" : "previousDesktop",
            "arguments": []
        });
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: container
        implicitWidth: root.Layout.preferredWidth
        implicitHeight: root.Layout.preferredHeight

        Rectangle {
            id: capsule
            anchors.centerIn: parent
            width: isVertical ? (parent.width - 4) : (mainRow.implicitWidth + 16)
            height: isVertical ? (mainRow.implicitHeight + 16) : Math.min(parent.height - 4, 26)
            radius: Math.min(width, height) / 2
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.45)
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: function(wheel) {
                    if (wheel.angleDelta.y > 0) {
                        root.switchByDelta(-1);
                    } else if (wheel.angleDelta.y < 0) {
                        root.switchByDelta(1);
                    }
                }
            }

            RowLayout {
                id: mainRow
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: root.desktopCount

                    delegate: Item {
                        id: dotItem
                        readonly property var dId: (vdInfo.desktopIds && vdInfo.desktopIds.length > index) ? vdInfo.desktopIds[index] : null
                        readonly property bool isCurrent: dId ? (vdInfo.currentDesktop === dId) : (index === 0)

                        implicitWidth: isVertical ? 8 : (isCurrent ? 22 : (dotMouse.containsMouse ? 12 : 8))
                        implicitHeight: isVertical ? (isCurrent ? 22 : (dotMouse.containsMouse ? 12 : 8)) : 8
                        Layout.alignment: Qt.AlignCenter

                        Behavior on implicitWidth {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                        Behavior on implicitHeight {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            id: dotRect
                            anchors.fill: parent
                            radius: Math.min(width, height) / 2

                            color: isCurrent 
                                ? Kirigami.Theme.highlightColor 
                                : (dotMouse.containsMouse 
                                    ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.8)
                                    : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.35))

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -1
                                radius: parent.radius + 1
                                color: "transparent"
                                border.color: isCurrent ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.7) : "transparent"
                                border.width: 1
                                visible: isCurrent
                            }
                        }

                        MouseArea {
                            id: dotMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                root.activateDesktopByIndex(index);
                            }

                            onWheel: function(wheel) {
                                if (wheel.angleDelta.y > 0) {
                                    root.switchByDelta(-1);
                                } else if (wheel.angleDelta.y < 0) {
                                    root.switchByDelta(1);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
