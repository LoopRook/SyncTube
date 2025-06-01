package server;

import server.DbManager;

class PlaylistCommands {
    public static var db:DbManager; // Must be set at startup!

    public static function handle(userId:String, message:String):Bool {
        if (!message.startsWith("/playlist")) return false;

        var args = message.split(" ");
        if (args.length < 3) {
            sendSystemMessage("Usage:\n/playlist add <name>\n/playlist switch <name>\n/playlist addvideo <name> <url>");
            return true;
        }

        var subcommand = args[1].toLowerCase();
        var playlistName = args[2];
        var url = args.length > 3 ? args.slice(3).join(" ") : null;

        switch(subcommand) {
            case "add":
                if (db.addPlaylist(playlistName))
                    sendSystemMessage("Playlist '" + playlistName + "' created!");
                else
                    sendSystemMessage("Could not create playlist '" + playlistName + "'.");
            case "switch":
                if (db.switchPlaylist(playlistName))
                    sendSystemMessage("Switched to playlist '" + playlistName + "'.");
                else
                    sendSystemMessage("Could not switch to playlist '" + playlistName + "'.");
            case "addvideo":
                if (url != null && db.addVideoToPlaylist(playlistName, url))
                    sendSystemMessage("Video added to playlist '" + playlistName + "'.");
                else
                    sendSystemMessage("Usage: /playlist addvideo <name> <url>");
            default:
                sendSystemMessage("Unknown subcommand for /playlist.");
        }
        return true;
    }

    static function sendSystemMessage(msg:String) {
        // Replace this with your actual system message broadcast if you want users to see it.
        trace('[System] ' + msg);
    }
}
