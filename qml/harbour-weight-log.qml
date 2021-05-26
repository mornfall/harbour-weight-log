// -*- qml -*- (c) 2014 Petr Ročkai <me@mornfall.net>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"

ApplicationWindow
{
    id: main
    property double avg_month: 0
    property double avg_week: 0

    initialPage: Component { Overview { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    function list() {
        return pageStack.push(Qt.resolvedUrl("pages/List.qml"));
    }

    function enter(p, date) {
        return pageStack.push(Qt.resolvedUrl("pages/Entry.qml"),
                              { parentPage: p == null ? initialPage : p,
                                initialDate: date == null ? new Date() : date });
    }
}


