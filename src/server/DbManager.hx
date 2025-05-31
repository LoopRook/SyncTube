package server;

import js.node.Fs;
import js.node.Path;

class DbManager {
    var db:Dynamic;

    function mkdirRecursive(path:String):Void {
        untyped __js__('require("fs").mkdirSync(path, { recursive: true })');
    }

    public function new(path:String) {
        var dir = Path.dirname(path);
        if (!Fs.existsSync(dir)) {
            mkdirRecursive(dir);
        }

        var sqlite3 = untyped __js__("require('sqlite3').verbose()");
        db = untyped __js__("new sqlite3.Database(path)");
        trace("DB ready: " + path);

        db.run('CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)');
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
