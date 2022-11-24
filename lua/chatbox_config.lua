/**
* General configuration
**/

-- Title of the chatbox.
-- Here are special titles:
-- %hostname% : Shows the server's name
-- %players% : Shows the player count on the server
-- %uptime% : Uptime of the server
LOUNGE_CHAT.ChatTitle = "BoomCityRP (%players%)"

-- Show the player's avatar when sending a message
LOUNGE_CHAT.ShowPlayerAvatar = false

-- Message display style
-- 0: Default
-- 1: Discord-like (enable ShowPlayerAvatar for better effect)
LOUNGE_CHAT.MessageStyle = 1

-- Name to display when the console sends a message
-- Parsers are allowed.
LOUNGE_CHAT.ConsoleName = "Console"

-- Whether to use Workshop or the FastDl for the custom content used by the add-on
LOUNGE_CHAT.UseWorkshop = true

-- Prevent players from using parsers in their name?
LOUNGE_CHAT.DisallowParsersInName = false

/**
* Profanity filter
**/

-- Which usergroups are allowed to bypass the profanity filter?
LOUNGE_CHAT.ProfanityBypass = {
	["superadmin"] = true
}

-- Words filtered out by the profanity filter. Case insensitive.
-- Do keep in mind that this profanity filter iS CLIENTSIDE. It will not kick out players for saying banned words.
-- Use a dedicated script for that.
-- You can also use lua patterns to have better detection: http://lua-users.org/wiki/PatternsTutorial
LOUNGE_CHAT.ProfanityFilter = {
	"pute",
    "merde",
    "fils de",
    "fdp",
    "batard",
    "connard",
    "salope",
    "chienne",
    "pen",
}

-- Character to use when censoring banned words.
-- Example: shit -> ****
LOUNGE_CHAT.CensorCharacter = "*"

/**
* Advanced configuration
* Only modify these if you know what you're doing.
**/

-- How the <timestamp=...> markup should be formatted.
-- See https://msdn.microsoft.com/en-us/library/fe06s4ak.aspx for a list of available mappings
LOUNGE_CHAT.TimestampFormat = "%c"

-- Where downloaded images should be in GMod's data folder.
LOUNGE_CHAT.ImageDownloadFolder = "fallout_chat_downloads"

-- Whether to use UTF-8 mode for character wrapping and parsing.
-- You can set this to false if your server's main language is Roman script only (English, etc)
LOUNGE_CHAT.UseUTF8 = false

-- Maximum messages allowed in the chatbox before deletion of the oldest messages.
LOUNGE_CHAT.MaxMessages = 200

-- Disable having to wrap an emoticon's name in : (like :thumb_up: becomes thumb_up)
-- This option has not been fully tested in all the possible cases so some text might look bad, or might straight up crash
-- the client. Change at your own risk.
LOUNGE_CHAT.EmoticonsNoColon = false

/**
* Style configuration
**/

-- Font to use for normal text throughout the chatbox.
LOUNGE_CHAT.FontName = "Circular Std Medium"

-- Font to use for bold text throughout the chatbox.
LOUNGE_CHAT.FontNameBold = "Circular Std Bold"

-- Color sheet.
LOUNGE_CHAT.Style = {
	header = Color(90, 94, 107, 100),
	bg = Color(90, 94, 107, 100),
	inbg = Color(0, 0, 0, 150),

	close_hover = Color(231, 76, 60),
	hover = Color(255, 255, 255, 10),
	hover2 = Color(255, 255, 255, 5),

	text = Color(255, 255, 255),
	text_down = Color(0, 0, 0),

	url = Color(52, 152, 219),
	url_hover = Color(62, 206, 255),
	timestamp = Color(166, 166, 166),

	menu = Color(127, 140, 141),
}

LOUNGE_CHAT.Anims = {
	FadeInTime = 0.15,
	FadeOutTime = 0.07,
	TextFadeOutTime = 1,
}

-- Size of the <glow> parser.
LOUNGE_CHAT.BlurSize = 2

/**
* Language configuration
**/

-- Various strings used throughout the chatbox. Change them to your language here.
-- %s and %d are special strings replaced with relevant info, keep them in the string!

-- FRENCH Translation: https://pastebin.com/pnQfQ82k

LOUNGE_CHAT.Language = {
	players_online = "Joueurs en ligne",
	server_uptime = "Temps Total du serveur :",
	click_to_load_image = "Clic pour charger l'image",
	failed_to_load_image = "Fail pour charger l'image",
	click_here_to_view_x_profile = "Clic ici pour voir %s's profil",

	chat_options = "Chat options",
	clear_chat = "Clear chat",
	reset_position = "Reset position",
	reset_size = "Reset size",

	chat_parsers = "Chat parsers",
	usage = "Usage",
	example = "Exemple",

	send = "Envoyer",
	copy_message = "Copie message",
	copy_url = "Copie URL",

	-- options
	general = "General",
	chat_x = "X position",
	chat_y = "Y position",
	chat_width = "Chatbox width",
	chat_height = "Chatbox height",
	time_before_messages_hide = "Time before messages fade out",
	show_timestamps = "Display timestamps",
	clear_downloaded_images = "Clear downloaded images folder (%s)",
	dont_scroll_chat_while_open = "Do not automatically scroll chat down while open",

	display = "Display",
	hide_images = "Cacher images",
	hide_avatars = "Cacher avatars",
	use_rounded_avatars = "Utiliser les avatars ronds",
	disable_flashes = "Désactiver les flashs",
	no_url_parsing = "Ne pas afficher les liens",
	autoload_external_images = "Chargement auto des images",
	hide_options_button = "Cacher le boutton des options",
}