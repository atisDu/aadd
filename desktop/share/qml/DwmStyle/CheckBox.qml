import QtQuick
import QtQuick.Templates as T

// Breeze-sized checkbox (17x17) in dwm colours
T.CheckBox {
    id: control
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    padding: 2
    spacing: 6
    opacity: enabled ? 1 : 0.4

    indicator: Rectangle {
        implicitWidth: 17
        implicitHeight: 17
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
                        : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: 4
        color: control.checkState === Qt.Unchecked ? "#282a2e" : "#eeeeee"
        border.color: control.checkState !== Qt.Unchecked ? "#eeeeee" : control.hovered ? "#888888" : "#444444"

        Text {
            anchors.centerIn: parent
            visible: control.checkState === Qt.Checked
            text: "✓"
            font.pixelSize: 13
            font.bold: true
            color: "#1d1f21"
        }
        Rectangle {
            anchors.centerIn: parent
            visible: control.checkState === Qt.PartiallyChecked
            width: 9
            height: 2
            color: "#1d1f21"
        }
    }

    contentItem: Text {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        font: control.font
        color: "#eeeeee"
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
}
