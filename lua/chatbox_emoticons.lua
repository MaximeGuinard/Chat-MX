/**
* Derma Emoticons 
**/

-- Enable Derma emoticons?
-- You can see the full list here: http://www.famfamfam.com/lab/icons/silk/previews/index_abc.png
LOUNGE_CHAT.EnableDermaEmoticons = true

-- Restrict Derma emoticons?
-- You can configure the restrictions in the "DermaEmoticonsRestrictions" option.
-- "false" means derma emoticons can be used by anyone.
LOUNGE_CHAT.RestrictDermaEmoticons = false

-- Here you can decide on restrictions for players to be able to use Derma emoticons in their messages.
-- Only works if the "RestrictDermaEmoticons" option is set to true
LOUNGE_CHAT.DermaEmoticonsRestrictions = {
	-- This means only admins, superadmins and players with the specific SteamID/SteamID64 can use Derma emoticons.
	usergroups = {"admin", "superadmin"},
	steamids = {"STEAM_0:1:8039869", "76561197976345467"}
}

/**
* Custom Emoticons 
**/

-- Add your custom emoticons here!
-- Two examples are provided for you to copy.
LOUNGE_CHAT.CustomEmoticons = {
	-- This creates a "grin" emoticon with the material "vgui/face/grin"
	["grin"] = {
		path = "vgui/face/grin",
		w = 64,
		h = 32,
	},

	-- This creates a "awesomeface" emoticon with the URL "http://i.imgur.com/YBUpyZg.png"
	["awesomeface"] = {
		url = "http://i.imgur.com/YBUpyZg.png",
		w = 32,
		h = 32,
	},

	// FA emoticons
	["kami"] = {
		url = "https://vgy.me/pzfz8k.png",
		w = 32,
		h = 32,
	},
	["kosmugi"] = {
		url = "http://i.imgur.com/fWxbVLv.png",
		w = 32,
		h = 32,
	},
	["chaika"] = {
		url = "http://i.imgur.com/h25fTDE.png",
		w = 32,
		h = 32,
	},
	["thatcat"] = {
		url = "http://i.imgur.com/00Xaj13.png",
		w = 32,
		h = 32,
	},
}

-- Here you can decide whether an emoticon can only be used by a specific usergroup/SteamID
LOUNGE_CHAT.EmoticonRestriction = {
	-- This restricts the "awesomeface" emoticon so that it can only be used by:
	-- * "admin" and "superadmin" usergroups
	-- * players with the SteamID "STEAM_0:1:8039869" or SteamID64 "76561197976345467"
	["awesomeface"] = {
		usergroups = {"admin", "superadmin"},
		steamids = {"STEAM_0:1:8039869", "76561197976345467"}
	},
}

/**
* End of configuration
**/

LOUNGE_CHAT.Emoticons = {}

function LOUNGE_CHAT:RegisterEmoticon(id, path, url, w, h, restrict)
	self.Emoticons[id] = {
		path = path,
		url = url,
		w = w or 16,
		h = h or 16,
		restrict = restrict,
	}
end

if (LOUNGE_CHAT.EnableDermaEmoticons) then
	local fil = file.Find("materials/icon16/*.png", "GAME")
	for _, f in pairs (fil) do
		local restrict
		if (LOUNGE_CHAT.RestrictDermaEmoticons) then
			restrict = LOUNGE_CHAT.DermaEmoticonsRestrictions
		end

		LOUNGE_CHAT:RegisterEmoticon(string.StripExtension(f), "icon16/" .. f, nil, 16, 16, restrict)
	end
end

for id, em in pairs (LOUNGE_CHAT.CustomEmoticons) do
	LOUNGE_CHAT:RegisterEmoticon(id, em.path, em.url, em.w, em.h, LOUNGE_CHAT.EmoticonRestriction[id])
end