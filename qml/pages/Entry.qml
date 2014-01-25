// -*- qml -*- (c) 2014 Petr Ročkai <me@mornfall.net>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../storage.js" as DB

Dialog {
    id: page
    property date initialDate: new Date()

    SilicaFlickable {
        id: entry
        anchors.fill: parent

        Column {
            anchors.fill: parent

            DialogHeader {
                acceptText: DB.hasDate(date.date) ? "Update" : "Add"
            }

            DatePickerDialog {
                id: date
                date: page.initialDate
                width: parent.width
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                Label { text: "Date:"
                        anchors.verticalCenter: parent.verticalCenter }
                Button {
                    text: Qt.formatDate(date.date, "yyyy-MM-dd")
                    onClicked: date.open()
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextField {
                id: weight
                inputMethodHints: Qt.ImhDigitsOnly
                label: "Weight"
                placeholderText: "enter your weight"
                width: parent.width
                focus: true
            }

            Text {
                text: {
                    var d = DB.hasDate(date.date);
                    if (!d)
                        return "";
                    return "Note: You already have an entry " +
                           "for this date: <strong>" + d + "</strong>";
                }
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: parent.width
                color: Theme.primaryColor
            }
        }
    }
    canAccept: weight.text.length > 0
    onAccepted: {
        DB.insert(date.date, Number.fromLocaleString(Qt.locale(), weight.text));
        pageStack.find( function(p) {
            try { p.refresh(); } catch (e) {};
            return false;
        } );
    }

}
