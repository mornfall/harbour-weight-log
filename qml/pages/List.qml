// -*- qml -*- (c) 2014 Petr Ročkai <me@mornfall.net>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../storage.js" as DB

Page {
    ListModel {
        id: listmodel
    }

    id: list
    function refresh() { listmodel.clear(); DB.list(listmodel); }

    SilicaFlickable {
        anchors.fill: parent


        PageHeader {
            title: "Entry List"
            id: header
        }

        PullDownMenu {
            MenuItem {
                text: "Delete All"
                onClicked: remorse.execute( "Deleting All Entries",
                                           function() { DB.clear();
                                                        list.refresh() } )
            }
            MenuItem {
                text: "New Entry"
                onClicked: main.enter(list)
            }
        }

        RemorsePopup { id: remorse }

        SilicaListView {
            id: listview
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            model: listmodel

            delegate: ListItem {
                id: listitem
                width: parent.width
                menu: contextmenu
                anchors.horizontalCenter: parent.horizontalCenter

                Row {
                    spacing: 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: date
                        text: Qt.formatDate(model.date, "yyyy-MM-dd")
                    }

                    Label {
                        text: model.weight
                    }
                }

                Component {
                    id: contextmenu

                    ContextMenu {
                        MenuItem {
                            text: "Edit"
                            onClicked: main.enter(list, model.date);
                        }
                        MenuItem {
                            text: "Delete"
                            onClicked: {
                                DB.remove(model.date.valueOf());
                                list.refresh();
                            }
                        }
                    }
                }
            }
        }
        Component.onCompleted: list.refresh()
    }

}
