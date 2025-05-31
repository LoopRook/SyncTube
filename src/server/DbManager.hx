package server;

import js.node.Fs;
import js.node.Path;

class DbManager {
    var db:Dynamic;
    var ready:Bool = false;
    var onReadyCallbacks:Array<Void->Void> = [];

    function mkdirRecursive(path:String):Void {
        untyped __js__('require("fs").mkdirSync(path, { recursive: true })');
    }

    public function new(path:String) {
        var dir = Path.dirname(path);
        if (!Fs.existsSync(dir)) {
            mkdirRecursive(dir);
        }

        var sqlite3 = untyped __js__("require('sqlite3').verbose()");
        var onOpenCallback = untyped __js__("function(err) {\\n" +
            "if (err) { console.log('DB error: ' + err); return; }\\n" +
            "console.log('DB ready: ' + path);\\n" +
            "db.run('CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)', [], function(err2) {\\n" +
            "if (err2) { console.log('Error creating table: ' + err2); return; }\\n" +
            "});\\n" +
            "}");

        db = untyped __js__("new sqlite3.Database(path, onOpenCallback)", { path : path, onOpenCallback : onOpenCallback });
    }

    private function ensureReady(cb:Void->Void):Void {
        if (ready) cb();
        else onReadyCallbacks.push(cb);
    }

    public function addPlaylist(name:String, description:String):Void {
        ensureReady(() -> {
            db.run('INSERT INTO playlists (name, description) VALUES (?, ?)', [name, description], function(err) {
                if (err != null) trace("Add playlist error: " + err);
                else trace("Playlist added!");
            });
        });
    }

    public function getPlaylists():Void {
        ensureReady(() -> {
            db.all('SELECT * FROM playlists', function(err, rows) {
                if (err != null) trace("Get playlists error: " + err);
                else trace(rows);
            });
        });
    }
}
