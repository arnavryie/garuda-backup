import QtQuick 2.4
import QtQuick.Controls
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami as Kirigami

Rectangle{

    id:item

    implicitHeight: Math.floor( Kirigami.Units.gridUnit * 1.8)
    width: Math.floor(lb.implicitWidth + Kirigami.Units.smallSpacing * 5 + icon.width)


    border.width: mouseItem.containsMouse || focus || activeFocus  ? 2 : 1
    border.color: mouseItem.containsMouse || focus || activeFocus ? Kirigami.Theme.highlightColor  : colorWithAlpha(Kirigami.Theme.textColor,0.2)
    radius: 3
    color: Kirigami.Theme.backgroundColor
    smooth: true // Plasmoid.configuration.iconSmooth
    focus: true

    property alias text: lb.text
    property bool flat: false
    property alias iconName: icon.source
    property bool mirror: false

    signal clicked

    //Keys.onEnterPressed: item.clicked()
    Keys.onSpacePressed: item.clicked()

    RowLayout{
        id: row
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.rightMargin: Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing
        LayoutMirroring.enabled: mirror

        Label{
            id: lb
            color: Kirigami.Theme.textColor
        }
        Kirigami.Icon {
            id: icon
            implicitHeight: Kirigami.Units.gridUnit
            implicitWidth: implicitHeight
            smooth: true // Plasmoid.configuration.iconSmooth
        }
    }

    MouseArea {
        id: mouseItem
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: item.clicked()
    }

}
