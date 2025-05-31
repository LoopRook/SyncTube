package server;

import js.node.fs;
import js.node.path;

class DbManager {
    var db:Dynamic;

    public function new(path:String) {
        var dir = path.split('/').slice(0, -1).join('/');
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
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
