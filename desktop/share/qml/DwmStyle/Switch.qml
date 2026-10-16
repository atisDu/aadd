import QtQuick
import QtQuick.Templates as T

// Breeze-sized switch (34x17) in dwm colours; everything else falls back to Material (see qmldir)
T.Switch {
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
        implicitWidth: 34
        implicitHeight: 17
        x: control.text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding)
                        : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2
        radius: height / 2
        color: control.checked ? "#eeeeee" : "#282a2e"
        border.color: control.checked ? "#eeeeee" : "#444444"

        Rectangle {
            y: 2
            x: control.checked ? parent.width - width - 2 : 2
            width: parent.height - 4
            height: width
            radius: width / 2
            color: control.checked ? "#1d1f21" : control.hovered ? "#aaaaaa" : "#888888"
            Behavior on x { NumberAnimation { duration: 120 } }
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
