package server;

import js.node.Fs;
import js.node.Path;

class DbManager {
    var db:Dynamic;
    var ready:Bool = false;
    var onReadyCallbacks:Array<Void->Void> = [];

    function mkdirRecursive(path:String):Void {
        untyped __js__('require("fs").mkdirSync(path, { recursive: true });');
    }

    public function new(path:String) {
        var dir:String = Path.dirname(path);
        if (!Fs.existsSync(dir)) {
            mkdirRecursive(dir);
        }

        var sqlite3:Dynamic = untyped __js__("require('sqlite3').verbose();");

        var onOpenCallback:Dynamic = function(err:Dynamic):Void {
            if (err != null) {
                trace("DB error: " + err);
                return;
            }
            trace("DB ready");
            db.run(
                "CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)",
                [],
                function(err2:Dynamic):Void {
                    if (err2 != null) {
                        trace("Error creating table: " + err2);
                        return;
                    }
                    ready = true;
                    for (cbFunc in onReadyCallbacks) {
                        cbFunc();
                    }
                    onReadyCallbacks = [];
                }
            );
        };

        db = untyped __js__("new sqlite3.Database(path, onOpenCallback);");
    }

    private function ensureReady(cbFunc:Void->Void):Void {
        if (ready) {
            cbFunc();
        } else {
            onReadyCallbacks.push(cbFunc);
        }
    }

    public function addPlaylist(name:String, description:String):Void {
        ensureReady(() -> {
            db.run(
                "INSERT INTO playlists (name, description) VALUES (?, ?)",
                [name, description],
                function(err:Dynamic):Void {
                    if (err != null) {
                        trace("Add playlist error: " + err);
                    } else {
                        trace("Playlist added!");
                    }
                }
            );
        });
    }

    public function getPlaylists():Void {
        ensureReady(() -> {
            db.all(
                "SELECT * FROM playlists",
                function(err:Dynamic, rows:Dynamic):Void {
                    if (err != null) {
                        trace("Get playlists error: " + err);
                    } else {
                        trace("Current playlists:");
                        var list:Array<Dynamic> = cast rows;
                        for (pl in list) {
                            trace("ID: " + pl.id + ", Name: " + pl.name + ", Description: " + pl.description + "");
                        }
                    }
                }
            );
        });
    }
}

import js.node.Fs;
import js.node.Path;

class DbManager {
    var db:Dynamic;
    var ready:Bool = false;
    var onReadyCallbacks:Array<Void->Void> = [];

    function mkdirRecursive(path:String):Void {
        untyped __js__('require("fs").mkdirSync(path, { recursive: true });');
    }

    public function new(path:String) {
        var dir = Path.dirname(path);
        if (!Fs.existsSync(dir)) {
            mkdirRecursive(dir);
        }

        var sqlite3 = untyped __js__("require('sqlite3').verbose();");

        var onOpenCallback = function(err:Dynamic):Void {
            if (err != null) {
                trace("DB error: " + err);
                return;
            }
            trace("DB ready");
            db.run(
                'CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, description TEXT)',
                [],
                function(err2:Dynamic):Void {
                    if (err2 != null) {
                        trace("Error creating table: " + err2);
                        return;
                    }
                    ready = true;
                    for (cb in onReadyCallbacks) {
                        cb();
                    }
                    onReadyCallbacks = [];
                }
            );
        };

        db = untyped __js__("new sqlite3.Database(path, onOpenCallback);");
    }

    private function ensureReady(cb:Void->Void):Void {
        if (ready) {
            cb();
        } else {
            onReadyCallbacks.push(cb);
        }
    }

    public function addPlaylist(name:String, description:String):Void {
        ensureReady(() -> {
            db.run(
                'INSERT INTO playlists (name, description) VALUES (?, ?)',
                [name, description],
                function(err:Dynamic):Void {
                    if (err != null) {
                        trace("Add playlist error: " + err);
                    } else {
                        trace("Playlist added!");
                    }
                }
            );
        });
    }

    public function getPlaylists():Void {
        ensureReady(() -> {
            db.all(
                'SELECT * FROM playlists',
                function(err:Dynamic, rows:Dynamic):Void {
                    if (err != null) {
                        trace("Get playlists error: " + err);
                    } else {
                        trace("Current playlists:");
                        var list = cast rows:Array<Dynamic>;
                        for (playlist in list) {
                            trace("ID: " + playlist.id + ", Name: " + playlist.name + ", Description: " + playlist.description);
                        }
                    }
                }
            );
        });
    }
}
