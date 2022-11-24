/**
* Tags configuration
* This is not a dedicated tags add-on, there are probably better add-ons out there for tags.
**/

-- Tag to display for a dead player's message in the CHAT
-- You can use parsers here.
LOUNGE_CHAT.TagDead = "<color=255,0,0>*MORT*</color> "

-- Tag to display for a player's team message in the CHAT
-- The color preceding this will be the player's team color.
-- You can use parsers here.
LOUNGE_CHAT.TagTeam = "(TEAM) "

-- Tag to display for a dead player's message in the CONSOLE
-- You can't put parsers in there. What you can do is use a table for different text/colors.
LOUNGE_CHAT.TagDeadConsole = {Color(255, 0, 0), "*MORT* "}

-- Tag to display for a player's team message in the CONSOLE
-- The color preceding this will be the player's team color.
-- You can't put parsers in there. What you can do is use a table for different text/colors.
LOUNGE_CHAT.TagTeamConsole = {"(TEAM) "}

/**
* Name Color configuration
*/

-- Here you can set up custom name colors for specific usergroups.
-- By default the name color is the player's team color.
LOUNGE_CHAT.CustomColorsGroups = {
	["superadmin"] = Color(0, 255, 42),
}

-- Here you can set up custom name colors for specific players.
-- This takes priority over the usergroup custom color.
-- By default the name color is the player's team color.
LOUNGE_CHAT.CustomColorsPlayers = {
}

/**
* Team Tags configuration
*/

-- Set to true to display the player's team name before their name.
LOUNGE_CHAT.TeamTags = false

-- Set to 1 to change the team tag's case to uppercase.
-- Set to -1 to change it to lowercase.
LOUNGE_CHAT.TeamTagsCase = 1

-- (Advanced) String format of the team tag. Leave it alone if you don't know what this does.
LOUNGE_CHAT.TeamTagsFormat = "[%s]"

/**
* DayZ Tags configuration
* Because the generic DayZ gamemode for sale on gmodstore is terribly coded in general,
* we have to discard its tag system and use our own instead.
* Don't touch this if you don't know what this does.
**/

local ooc = {
	tagcolor = Color(100, 100, 100),
	tag = "[OOC] ",
}

LOUNGE_CHAT.DayZ_ChatTags = {
	["!"] = {
		["ooc"] = ooc,
		["g"] = ooc,
		["y"] = ooc,
	},
	["/"] = {
		["ooc"] = ooc,
		["g"] = ooc,
		["y"] = ooc,
		["/"] = ooc,
	},
}

/**
* Custom Tags configuration
* If aTags is installed, this won't be used at all.
**/

-- Enable custom tags for specific usergroups/players.
LOUNGE_CHAT.EnableCustomTags = true

-- Here is where you set up custom tags for usergroups.
-- If there's a custom tag for a specific SteamID/SteamID64, it'll take priority over the one here.
-- If you don't want a group to have a custom tag, then don't put it in the table.
-- You can use parsers here.
LOUNGE_CHAT.CustomTagsGroups = {
	["user"] = ":new: <color=0,255,0> [Joueur] </color>.",
	["Modérateur"] = ":scratchnumber: ^009[Modérateur]",
	["admin"] = ":comments: <defc=red> [Administrateur]",
	["Admin+"] = ":comments: <defc=red> [Administrateur+]",
	["superadmin"] = ":shield_add: <rainbow=2> [S-Admin] </rainbow>",
}

-- Here is where you set up custom tags for specific players. Accepts SteamIDs and SteamID64s.
-- This takes priority over the usergroup custom tag.
-- You can use parsers here.
LOUNGE_CHAT.CustomTagsPlayers = {
}