package server;

import sys.db.Connection;
import sys.db.Sqlite;
import haxe.ds.StringMap;

class DbManager {
    var conn:Connection;
    public function new(path:String) {
        conn = Sqlite.open(path);
        init();
    }
    
    function init():Void {
        conn.request("CREATE TABLE IF NOT EXISTS playlists (id INTEGER PRIMARY KEY AUTOINCREMENT, room_id TEXT, name TEXT, UNIQUE(room_id, name));");
        conn.request("CREATE TABLE IF NOT EXISTS playlist_videos (id INTEGER PRIMARY KEY AUTOINCREMENT, playlist_id INTEGER, url TEXT);");
        // Track active playlist per room
        conn.request("CREATE TABLE IF NOT EXISTS active_playlists (room_id TEXT PRIMARY KEY, playlist_id INTEGER);");
    }

    // Add a new playlist for a specific room
    public function addPlaylist(roomId:String, name:String):Bool {
        try {
            conn.request('INSERT INTO playlists (room_id, name) VALUES (?, ?)', [roomId, name]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    // Switch the active playlist for a room
    public function switchPlaylist(roomId:String, name:String):Bool {
        var result = conn.request('SELECT id FROM playlists WHERE room_id = ? AND name = ?', [roomId, name]);
        if (!result.hasNext()) return false;
        var playlistId = result.next().id;
        try {
            conn.request('INSERT OR REPLACE INTO active_playlists (room_id, playlist_id) VALUES (?, ?)', [roomId, playlistId]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    // Add video to specific playlist (by room and name)
    public function addVideoToPlaylist(roomId:String, playlistName:String, url:String):Bool {
        try {
            var playlistIdResult = conn.request('SELECT id FROM playlists WHERE room_id = ? AND name = ?', [roomId, playlistName]);
            if (!playlistIdResult.hasNext()) return false;
            var playlistId = playlistIdResult.next().id;
            conn.request('INSERT INTO playlist_videos (playlist_id, url) VALUES (?, ?)', [playlistId, url]);
            return true;
        } catch (e:Dynamic) {
            return false;
        }
    }

    // Get all playlist names for a room
    public function getPlaylists(roomId:String):Array<String> {
        var names = [];
        var result = conn.request('SELECT name FROM playlists WHERE room_id = ?', [roomId]);
        while (result.hasNext()) {
            names.push(result.next().name);
        }
        return names;
    }

    // Get all videos in a named playlist for a room
    public function getPlaylistVideos(roomId:String, playlistName:String):Array<String> {
        var videos = [];
        var res = conn.request('SELECT id FROM playlists WHERE room_id = ? AND name = ?', [roomId, playlistName]);
        if (!res.hasNext()) return videos;
        var playlistId = res.next().id;
        var result = conn.request('SELECT url FROM playlist_videos WHERE playlist_id = ?', [playlistId]);
        while (result.hasNext()) {
            videos.push(result.next().url);
        }
        return videos;
    }

    // Get the current active playlist name for a room
    public function getActivePlaylist(roomId:String):Null<String> {
        var apRes = conn.request('SELECT playlist_id FROM active_playlists WHERE room_id = ?', [roomId]);
        if (!apRes.hasNext()) return null;
        var playlistId = apRes.next().playlist_id;
        var plRes = conn.request('SELECT name FROM playlists WHERE id = ?', [playlistId]);
        if (!plRes.hasNext()) return null;
        return plRes.next().name;
    }
}
