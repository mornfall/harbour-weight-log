// -*- qml -*- (c) 2014 Petr Ročkai <me@mornfall.net>

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../storage.js" as DB


Page {
    id: overview
    Component.onCompleted: refresh()

    function today() {
        return DB.day(new Date());
    }

    function refresh() {
        main.avg_month = avg(28);
        main.avg_week = avg(7);
        plot.requestPaint();
        console.log("hi there from refresh...");
    }

    function paint(ctx) {
        var start = today() - 28;
        function run(cb) { DB.plot( start, today(), cb ); }

        var xmin = 1000, xmax = 0, ymin = 1000, ymax = 0;
        run( function(d, w, a) {
            console.log("plot: " + (d - start) + ", " + w + ", " + a);
            xmin = Math.min( xmin, d - start );
            xmax = Math.max( xmax, d - start );
            ymin = Math.ceil( Math.min( ymin, w, a ) );
            ymax = Math.floor( Math.max( ymax, w, a ) );
        } );

        xmax = xmax - xmin < 8 ? xmin + 8 : xmax;
        if (ymax - ymin  < 5) {
            ymax = ymin + 4;
            ymin --;
        }

        console.log("bounds: " + xmin + ", " + xmax + "; " + ymin + ", " + ymax);
        // ctx.translate( xmin, ymin );
        // ctx.scale( plot.width / (xmax - xmin),
        //            plot.height / (ymax - ymin) );
        var xscale = (plot.width - 10) / (xmax - xmin);
        var yscale = (plot.height - 10) / (ymax - ymin);

        function xt(x) { return 5 + (x - xmin) * xscale; }
        function yt(y) { return plot.height - (5 + (y - ymin) * yscale); }

        function moveTo(x, y) { ctx.moveTo( xt(x), yt(y) ); }
        function lineTo(x, y) { ctx.lineTo( xt(x), yt(y) ); }
        function circle(x, y, r) { ctx.arc( xt(x), yt(y), r, 0, 360 ); }

        ctx.save();
        ctx.clearRect(0, 0, plot.width, plot.height);

        ctx.beginPath(); ctx.strokeStyle = ctx.fillStyle = "gray";
        for ( var y = ymin; y < ymax; ++y ) {
            moveTo( xmin, y ); lineTo( xmax, y );
        }
        ctx.stroke();

        for ( var y = ymin; y < ymax; ++y )
            ctx.fillText( y, xt(xmin), yt(y) - 5 );

        ctx.beginPath(); ctx.strokeStyle = "green";
        run( function(d, w, a) { lineTo( d - start, w ); } );
        ctx.stroke();

        ctx.beginPath(); ctx.strokeStyle = "red";
        run( function(d, w, a) { lineTo( d - start, a ); } );
        ctx.stroke();

        ctx.fillStyle = "red";
        run( function(d, w, a) {
            ctx.beginPath();
            circle( d - start, a, 5 );
            ctx.fill();
        } );

        ctx.restore();
    }

    function avg(days) {
        return DB.average(today() - days, today());
    }

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: "Edit Entries"
                onClicked: main.list()
            }
            MenuItem {
                text: "New Entry"
                onClicked: main.enter(overview)
            }
        }

        contentHeight: column.height

        Column {
            id: column

            width: overview.width
            spacing: Theme.paddingLarge
            anchors.fill: parent

            PageHeader {
                title: "Weight Log"
            }

            Canvas {
                id: plot
                height: overview.height / 2
                width: parent.width
                contextType: "2d"
                onAvailableChanged: overview.refresh()
                onPaint: overview.paint(getContext("2d"));
            }

            Label {
                id: month
                text: "Monthly Average: " + main.avg_month
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                id: week
                text: "Weekly Average: " + main.avg_week
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}


