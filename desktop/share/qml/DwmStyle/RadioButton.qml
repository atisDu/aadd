import QtQuick
import QtQuick.Templates as T

// Breeze-sized radio button (17x17) in dwm colours
T.RadioButton {
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
        radius: width / 2
        color: "#282a2e"
        border.color: control.checked ? "#eeeeee" : control.hovered ? "#888888" : "#444444"

        Rectangle {
            anchors.centerIn: parent
            visible: control.checked
            width: 7
            height: 7
            radius: width / 2
            color: "#eeeeee"
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
