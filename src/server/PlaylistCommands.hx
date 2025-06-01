package server;

import server.DbManager; // Update path if needed

class PlaylistCommands {
    public static function handle(roomId:String, userId:String, message:String):Bool {
        // Only handle /playlist commands
        if (!message.startsWith("/playlist")) return false;

        var args = message.split(" ");
        if (args.length < 3) {
            sendSystemMessage(roomId, "Usage:\n/playlist add <name>\n/playlist switch <name>\n/playlist addvideo <name> <url>");
            return true;
        }

        var subcommand = args[1].toLowerCase();
        var playlistName = args[2];
        var url = args.length > 3 ? args.slice(3).join(" ") : null;

        switch(subcommand) {
            case "add":
                if (DbManager.addPlaylist(roomId, playlistName))
                    sendSystemMessage(roomId, "Playlist '" + playlistName + "' created!");
                else
                    sendSystemMessage(roomId, "Could not create playlist '" + playlistName + "'.");
            case "switch":
                if (DbManager.switchPlaylist(roomId, playlistName))
                    sendSystemMessage(roomId, "Switched to playlist '" + playlistName + "'.");
                else
                    sendSystemMessage(roomId, "Could not switch to playlist '" + playlistName + "'.");
            case "addvideo":
                if (url != null && DbManager.addVideoToPlaylist(roomId, playlistName, url))
                    sendSystemMessage(roomId, "Video added to playlist '" + playlistName + "'.");
                else
                    sendSystemMessage(roomId, "Usage: /playlist addvideo <name> <url>");
            default:
                sendSystemMessage(roomId, "Unknown subcommand for /playlist.");
        }

        return true; // handled!
    }

    static function sendSystemMessage(roomId:String, msg:String) {
        // Replace this with your actual room broadcast or system message logic.
        // Example: RoomManager.broadcastSystem(roomId, msg);
        trace('[Room ' + roomId + '][System] ' + msg);
    }
}
