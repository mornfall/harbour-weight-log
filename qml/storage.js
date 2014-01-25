.pragma library
.import QtQuick.LocalStorage 2.0 as LS

// Get DB Connection, Initialize or Upgrade DB
function open() {
  try {
    var db = LS.LocalStorage.openDatabaseSync("harbour-weight-log", "", "Weight Log Storage", 1000000);

    if (db.version == "") {
      db.changeVersion("", "1",
        function(tx) {
          // date is measured in days since epoch
          tx.executeSql("CREATE TABLE IF NOT EXISTS entries(date INTEGER UNIQUE, weight REAL);");
        }
      );
    }
  } catch (e) {
    console.log("Could not open DB: " + e);
  }
  return db;
}

function day(date) {
    return Math.floor(date.valueOf() / (1000 * 3600 * 24));
}

function fromDay(day) {
    return new Date(day * 3600 * 24 * 1000);
}

function insert(date, weight) {
    withDB(
      function(tx) {
          var res = tx.executeSql("SELECT * from entries where date = ?", [day(date)]);
          if (res.rows.length)
              tx.executeSql("UPDATE entries SET weight = ? where date = ?", [weight, day(date)]);
          else
              tx.executeSql("INSERT INTO entries VALUES(?, ?);", [day(date), weight]);
      }
    )
}

function hasDate(date) {
    return withDB(function(tx) {
        return tx.executeSql("SELECT * from entries where date = ?",
                             [day(date)]).rows.item(0).weight;
    } );
}

/*
 * TODO Hold the "connection" open for the lifetime of the program.
 */
function withDB(cb) {
    var db = open();
    var res;
    try {
        db.transaction(function(tx) {
            res = cb(tx);
        } );
    } catch (e) {
        console.log("database transaction failed: " + e)
    }

    return res;
}

function list(model) {
    withDB(
      function(tx) {
        var res = tx.executeSql("select * from entries order by date;");
        for ( var i = 0; i < res.rows.length; i ++ ) {
            var r = res.rows.item(i);
            model.append({"date": fromDay(r.date),
                          "weight": r.weight});
        }
      }
    )
}

function average(from, to) {
    return withDB( function(tx) {
        var res = tx.executeSql("select AVG(weight) from entries where date >= ? and date <= ?", [from, to]);
        return res.rows.item(0)["AVG(weight)"];
    } );
}

function plot(from, to, cb) {
    return withDB( function(tx) {
        var res = tx.executeSql("select * from entries where date >= ? and date <= ? order by date",
                                [from - 10, to]);
        var weight = res.rows.item(0).weight;
        var day = res.rows.item(0).date - 1;
        var running = weight;

        for ( var i = 0; i < res.rows.length; i ++ ) {
            var r = res.rows.item(i);
            var day_inc = r.date - day;
            var weight_inc = r.weight - weight;

            while ( day < r.date ) {
                ++ day;
                weight += weight_inc / day_inc;
                running = running + (weight - running) / 10;

                if ( day >= from )
                    cb(day, weight, running);
            }
        }
    } );
}

function remove(date) {
    withDB( function(tx) {
        tx.executeSql("delete from entries where date = ?", [day(date)]);
    } );
}

function clear() {
    withDB( function(tx) {
        tx.executeSql("delete from entries");
    } );
}
