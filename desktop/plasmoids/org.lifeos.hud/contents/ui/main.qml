import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: "NoBackground"

    compactRepresentation: Item {
        implicitWidth: 36
        implicitHeight: 36
        Rectangle {
            anchors.fill: parent
            radius: 8
            color: mouseArea.containsMouse ? "#222222" : "#000000"
            border.color: "#33ffffff"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "⚡"
                font.pixelSize: 18
                color: "#ffffff"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    executable.exec("python3 /home/ryie/Documents/Projects/life-os/widgets/linux_desktop_widget.py")
                }
            }
        }
    }

    fullRepresentation: Item {
        id: fullView
        implicitWidth: 360
        implicitHeight: 280

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "#000000"
            border.color: "#22ffffff"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "⚡ J.A.R.V.I.S. HUD"
                        font.pixelSize: 13
                        font.bold: true
                        font.family: "monospace"
                        color: "#ffffff"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Qt.formatDateTime(new Date(), "hh:mm AP")
                        font.pixelSize: 11
                        font.family: "monospace"
                        color: "#888888"
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#18ffffff"
                }

                // Launch Desktop HUD Button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    contentItem: RowLayout {
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "🖥️ Launch Floating Desktop HUD"
                            font.pixelSize: 11
                            font.bold: true
                            font.family: "monospace"
                            color: "#000000"
                        }
                        Item { Layout.fillWidth: true }
                    }
                    background: Rectangle {
                        color: parent.down ? "#cccccc" : (parent.hovered ? "#e0e0e0" : "#ffffff")
                        radius: 10
                    }
                    onClicked: {
                        executable.exec("python3 /home/ryie/Documents/Projects/life-os/widgets/linux_desktop_widget.py")
                    }
                }

                Text {
                    text: "QUICK REDIRECT PORTALS"
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "monospace"
                    color: "#666666"
                }

                // Grid of 4 portals
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 6

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        contentItem: Text {
                            text: "LeetCode ↗"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "monospace"
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#222222" : "#111111"
                            border.color: "#22ffffff"
                            border.width: 1
                            radius: 8
                        }
                        onClicked: Qt.openUrlExternally("https://leetcode.com/u/arnavryie/")
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        contentItem: Text {
                            text: "Codeforces ↗"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "monospace"
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#222222" : "#111111"
                            border.color: "#22ffffff"
                            border.width: 1
                            radius: 8
                        }
                        onClicked: Qt.openUrlExternally("https://codeforces.com/profile/arnavryie")
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        contentItem: Text {
                            text: "CodeChef ↗"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "monospace"
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#222222" : "#111111"
                            border.color: "#22ffffff"
                            border.width: 1
                            radius: 8
                        }
                        onClicked: Qt.openUrlExternally("https://www.codechef.com/users/arnavryie")
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        contentItem: Text {
                            text: "GFG C++ ↗"
                            font.pixelSize: 10
                            font.bold: true
                            font.family: "monospace"
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: parent.hovered ? "#222222" : "#111111"
                            border.color: "#22ffffff"
                            border.width: 1
                            radius: 8
                        }
                        onClicked: Qt.openUrlExternally("https://www.geeksforgeeks.org/c-plus-plus/")
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        function exec(cmd) {
            connectSource(cmd)
        }
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
        }
    }
}
