package server;

import sys.db.Connection;
import sys.db.Sqlite;

class DbManager {
    var conn:Connection;
    public function new(path:String) {
        conn = Sqlite.open(path);
        init();
    }
    
    function init():Void {
        conn.request("CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE);");
        conn.request("CREATE TABLE IF NOT EXISTS playlist_videos (id INTEGER PRIMARY KEY AUTOINCREMENT, playlist_id INTEGER, url TEXT);");
        conn.request("CREATE TABLE IF NOT EXISTS active_playlist (id INTEGER PRIMARY KEY, playlist_id INTEGER);");
    }

    public function addPlaylist(name:String):Bool {
        try {
            conn.request('INSERT INTO playlists (name) VALUES (?)', [name]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    public function switchPlaylist(name:String):Bool {
        var result = conn.request('SELECT id FROM playlists WHERE name = ?', [name]);
        if (!result.hasNext()) return false;
        var playlistId = result.next().id;
        try {
            conn.request('INSERT OR REPLACE INTO active_playlist (id, playlist_id) VALUES (1, ?)', [playlistId]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    public function addVideoToPlaylist(playlistName:String, url:String):Bool {
        try {
            var playlistIdResult = conn.request('SELECT id FROM playlists WHERE name = ?', [playlistName]);
            if (!playlistIdResult.hasNext()) return false;
            var playlistId = playlistIdResult.next().id;
            conn.request('INSERT INTO playlist_videos (playlist_id, url) VALUES (?, ?)', [playlistId, url]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    public function getPlaylists():Array<String> {
        var names = [];
        var result = conn.request('SELECT name FROM playlists');
        while (result.hasNext()) {
            names.push(result.next().name);
        }
        return names;
    }

    public function getPlaylistVideos(playlistName:String):Array<String> {
        var videos = [];
        var res = conn.request('SELECT id FROM playlists WHERE name = ?', [playlistName]);
        if (!res.hasNext()) return videos;
        var playlistId = res.next().id;
        var result = conn.request('SELECT url FROM playlist_videos WHERE playlist_id = ?', [playlistId]);
        while (result.hasNext()) {
            videos.push(result.next().url);
        }
        return videos;
    }

    public function getActivePlaylist():Null<String> {
        var apRes = conn.request('SELECT playlist_id FROM active_playlist WHERE id = 1');
        if (!apRes.hasNext()) return null;
        var playlistId = apRes.next().playlist_id;
        var plRes = conn.request('SELECT name FROM playlists WHERE id = ?', [playlistId]);
        if (!plRes.hasNext()) return null;
        return plRes.next().name;
    }
}
