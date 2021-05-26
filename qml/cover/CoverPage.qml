// -*- qml -*- (c) 2014 Petr Ročkai <me@mornfall.net>

import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: appCover

    Image {
           source: "cover.png"
           anchors.horizontalCenter: parent.horizontalCenter
           width: parent.width
           height: sourceSize.height * width / sourceSize.width
       }

    Column {
        anchors.centerIn: parent

        Label {
            id: label
            text: "Weight Log"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Monthly: " + main.avg_month
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Weekly: " + main.avg_week
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-new"
            onTriggered: { main.enter(null); activate() }
        }
    }
}


