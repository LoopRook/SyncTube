package server;

import js.node.sqlite3.Database;

class DbManager {
    var db:Database;

    public function new(path:String) {
        db = new Database(path, function(err) {
            if (err != null) trace("DB error: " + err);
            else {
                trace("DB ready: " + path);
                db.run('CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)');
            }
        });
    }

    public function addPlaylist(name:String, description:String):Void {
        db.run('INSERT INTO playlists (name, description) VALUES (?, ?)', [name, description], function(err) {
            if (err != null) trace("Add playlist error: " + err);
            else trace("Playlist added!");
        });
    }

    public function getPlaylists():Void {
        db.all('SELECT * FROM playlists', function(err, rows) {
            if (err != null) trace("Get playlists error: " + err);
            else trace(rows);
        });
    }
}
