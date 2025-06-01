class PlaylistCommands {
    public static var db:DbManager;

    public static function handle(userId:String, message:String):Bool {
        if (!message.startsWith("/pl")) return false;

        var args = message.split(" ");
        if (args.length < 3) {
            sendSystemMessage("Usage:\n/pl add <name>\n/pl switch <name>\n/pl addvideo <name> <url>");
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
                    sendSystemMessage("Usage: /pl addvideo <name> <url>");
            default:
                sendSystemMessage("Unknown subcommand for /pl.");
        }
        return true;
    }

    static function sendSystemMessage(msg:String) {
        trace('[System] ' + msg);
    }
}
