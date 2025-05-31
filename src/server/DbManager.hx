package;

import sys.db.Sqlite;
import sys.db.Connection;
import sys.db.ResultSet;
import haxe.ds.Option;

class DbManager {
    var conn:Connection;

    public function new(dbPath:String) {
        try {
            conn = Sqlite.open(dbPath);
            trace('Connected to SQLite database at $dbPath');
            createTables();
        } catch (e:Dynamic) {
            trace('ERROR: Failed to connect to SQLite database: $e');
        }
    }

    function createTables():Void {
        // Playlists table
        conn.request('CREATE TABLE IF NOT EXISTS playlists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )');

        // Playlist items table
        conn.request('CREATE TABLE IF NOT EXISTS playlist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            playlist_id INTEGER NOT NULL,
            video_url TEXT NOT NULL,
            video_title TEXT,
            added_by TEXT,
            added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (playlist_id) REFERENCES playlists(id)
        )');

        // Cache metadata table
        conn.request('CREATE TABLE IF NOT EXISTS cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            video_url TEXT NOT NULL,
            video_title TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_accessed DATETIME DEFAULT CURRENT_TIMESTAMP
        )');
    }

    // ---- PLAYLIST API ----
    public function addPlaylist(name:String, ?description:String):Int {
        conn.request('INSERT INTO playlists (name, description) VALUES (?, ?)', [name, description]);
        var rs = conn.request('SELECT last_insert_rowid() AS id');
        return rs.next() ? rs.getIntResult(0) : -1;
    }

    public function getPlaylists():Array<{id:Int, name:String, description:String, created_at:String}> {
        var result = [];
        var rs = conn.request('SELECT id, name, description, created_at FROM playlists');
        while (rs.next()) {
            result.push({
                id: rs.getIntResult(0),
                name: rs.getResult(1),
                description: rs.getResult(2),
                created_at: rs.getResult(3)
            });
        }
        return result;
    }

    public function addPlaylistItem(playlist_id:Int, video_url:String, video_title:String, ?added_by:String):Int {
        conn.request('INSERT INTO playlist_items (playlist_id, video_url, video_title, added_by) VALUES (?, ?, ?, ?)', [playlist_id, video_url, video_title, added_by]);
        var rs = conn.request('SELECT last_insert_rowid() AS id');
        return rs.next() ? rs.getIntResult(0) : -1;
    }

    public function getPlaylistItems(playlist_id:Int):Array<{id:Int, video_url:String, video_title:String, added_by:String, added_at:String}> {
        var result = [];
        var rs = conn.request('SELECT id, video_url, video_title, added_by, added_at FROM playlist_items WHERE playlist_id = ?', [playlist_id]);
        while (rs.next()) {
            result.push({
                id: rs.getIntResult(0),
                video_url: rs.getResult(1),
                video_title: rs.getResult(2),
                added_by: rs.getResult(3),
                added_at: rs.getResult(4)
            });
        }
        return result;
    }

    // ---- CACHE API ----
    public function addCache(video_url:String, video_title:String):Int {
        conn.request('INSERT INTO cache (video_url, video_title) VALUES (?, ?)', [video_url, video_title]);
        var rs = conn.request('SELECT last_insert_rowid() AS id');
        return rs.next() ? rs.getIntResult(0) : -1;
    }

    public function getCache():Array<{id:Int, video_url:String, video_title:String, created_at:String, last_accessed:String}> {
        var result = [];
        var rs = conn.request('SELECT id, video_url, video_title, created_at, last_accessed FROM cache');
        while (rs.next()) {
            result.push({
                id: rs.getIntResult(0),
                video_url: rs.getResult(1),
                video_title: rs.getResult(2),
                created_at: rs.getResult(3),
                last_accessed: rs.getResult(4)
            });
        }
        return result;
    }

    // Optional: add more functions as needed!
}
