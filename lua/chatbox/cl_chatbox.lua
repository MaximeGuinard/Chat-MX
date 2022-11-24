-- TODO? save configs

local chat_x = CreateClientConVar("lounge_chat_x", 2 / 1080, true, false)
local chat_y = CreateClientConVar("lounge_chat_y", 0.52, true, false)
local chat_w = CreateClientConVar("lounge_chat_w", 550 / 1920, true, false)
local chat_h = CreateClientConVar("lounge_chat_h", 280 / 1080, true, false)
local chat_message_hidetime = CreateClientConVar("lounge_chat_hidetime", 15, true, false)
local chat_timestamps = CreateClientConVar("lounge_chat_timestamps", 0, true, false)
local chat_hide_options = CreateClientConVar("lounge_chat_hide_options", 0, true, false)
local chat_no_scroll_while_open = CreateClientConVar("lounge_chat_no_openscroll", 0, true, false)

--
cvars.AddChangeCallback("lounge_chat_x", function(cvar, old, new)
	if (IsValid(_LOUNGE_CHAT)) then
		local x = ScrW() * math.Clamp(tonumber(new) or chat_x:GetDefault(), 0, (ScrW() - _LOUNGE_CHAT:GetWide()) / ScrW())
		_LOUNGE_CHAT.x = x
	end
end)

cvars.AddChangeCallback("lounge_chat_y", function(cvar, old, new)
	if (IsValid(_LOUNGE_CHAT)) then
		local y = ScrH() * math.Clamp(tonumber(new) or chat_y:GetDefault(), 0, (ScrH() - _LOUNGE_CHAT:GetTall()) / ScrH())
		_LOUNGE_CHAT.y = y
	end
end)

cvars.AddChangeCallback("lounge_chat_w", function(cvar, old, new)
	if (IsValid(_LOUNGE_CHAT)) then
		local w = ScrW() * math.Clamp(tonumber(new) or chat_w:GetDefault(), 0, 1)
		_LOUNGE_CHAT:SetWide(w)
		_LOUNGE_CHAT.m_Close:AlignRight(0)
		_LOUNGE_CHAT.m_Options:MoveLeftOf(_LOUNGE_CHAT.m_Close)
	end
end)

cvars.AddChangeCallback("lounge_chat_h", function(cvar, old, new)
	if (IsValid(_LOUNGE_CHAT)) then
		local h = ScrH() * math.Clamp(tonumber(new) or chat_h:GetDefault(), 0, 1)
		_LOUNGE_CHAT:SetTall(h)
	end
end)

local chat_message_hidetime_cache = chat_message_hidetime:GetFloat()

cvars.AddChangeCallback("lounge_chat_hidetime", function(cvar, old, new)
	chat_message_hidetime_cache = tonumber(new) or 15
end)

--
local matClose = Material("shenesis/chat/close.png", "noclamp smooth")
local matSmile = Material("shenesis/chat/smile.png", "noclamp smooth")
local matOptions = Material("shenesis/chat/options.png", "noclamp smooth")

LOUNGE_CHAT.ChatboxOpen = false
LOUNGE_CHAT.History = {}

LOUNGE_CHAT.ChatboxFont = "LOUNGE_CHAT_18"
LOUNGE_CHAT.GlowFont = "LOUNGE_CHAT_18_G"
LOUNGE_CHAT.TimestampFont = "LOUNGE_CHAT_16"

local function IsPlayer(e)
	return type(e) == "Player" and IsValid(e)
end

local function RemoveIfValid(e)
	if (IsValid(e)) then
		e:Remove()
	end
end

local function FindPlayer(cont)
	for _, v in pairs (cont) do
		if (IsPlayer(v)) then
			return v
		end
	end

	return NULL
end

local nopaint = function() end

LOUNGE_CHAT.FontsToGlow = {}
LOUNGE_CHAT.FontsToBold = {}

function LOUNGE_CHAT:CreateChatboxFonts()
	local fntname = self.FontName
	local fntnamebold = self.FontNameBold
	local weight = 500
	local boldweight = 1000
	local sizes = {8, 10, 12, 14, 16, 18, 20, 24}

	for _, v in ipairs (sizes) do
		local n = "LOUNGE_CHAT_" .. v

		surface.CreateFont(n, {font = fntname, size = v, weight = weight})
		surface.CreateFont(n .. "_B", {font = fntnamebold, size = v, weight = boldweight})
		surface.CreateFont(n .. "_G", {font = fntnamebold, size = v, blursize = self.BlurSize, additive = true})

		self.FontsToGlow[n] = n .. "_G"
		self.FontsToBold[n] = n .. "_B"
	end
end

function LOUNGE_CHAT:CreateChatbox()
	RemoveIfValid(_LOUNGE_CHAT)
	RemoveIfValid(_LOUNGE_CHAT_EMOTICONS)

	local W, H = ScrW(), ScrH()
	local scale = math.Clamp(H / 1080, 0.7, 1)
	_LOUNGE_CHAT_SCALE = scale

	local wi, he = W * math.Clamp(chat_w:GetFloat(), 0, 1), H * math.Clamp(chat_h:GetFloat(), 0, 1)
	wi = math.max(wi, 400 * scale)
	he = math.max(he, 200 * scale)

	local x, y = W * math.Clamp(chat_x:GetFloat(), 0, (W - wi) / W), H * math.Clamp(chat_y:GetFloat(), 0, (H - he) / H)

	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:SetSizable(true)
	frame:SetScreenLock(true)
	frame:SetMinWidth(wi * 0.5)
	frame:SetMinHeight(he * 0.5)
	frame:SetSize(wi, he)
	frame:SetPos(x, y)
	frame:DockPadding(4, 27, 4, 4)
	frame.m_fAlpha = 0
	frame.Paint = function(me, w, h)
		if (gui.IsGameUIVisible()) then
			return end

		if (self.ChatboxOpen or me.m_fAlpha > 0) then
			local ch, cb = self.Color("header"), self.Color("bg")
			local a = me.m_fAlpha or 255
			local af = me.m_fAlphaFrac or 1

			draw.RoundedBoxEx(4, 0, 0, w, 22, Color(ch.r, ch.g, ch.b, ch.a * af), true, true, false, false)
			draw.RoundedBoxEx(4, 0, 22, w, h - 22, Color(cb.r, cb.g, cb.b, cb.a * af), false, false, true, true)

			me.m_Title:SetAlpha(a)
			me.m_Close:SetAlpha(a)
			me.m_Entry:SetAlpha(a)
			me.m_Send:SetAlpha(a)
			me.m_Title:PaintManual()
			me.m_Close:PaintManual()
			me.m_Entry:PaintManual()
			me.m_Send:PaintManual()
		end

		me.m_History:PaintManual()
	end
	frame.OldThink = frame.Think
	frame.Think = function(me)
		if (!self.ChatboxOpen) then
			return end

		local ox, oy = me.x, me.y
		local ow, oh = me:GetSize()

		me:OldThink()

		if (me.Dragging) then
			if (ox ~= me.x) then
				RunConsoleCommand("lounge_chat_x", tostring(ox / W))
			end
			if (oy ~= me.y) then
				RunConsoleCommand("lounge_chat_y", tostring(oy / H))
			end
		end

		if (me.Sizing) then
			if (ow ~= me:GetWide()) then
				RunConsoleCommand("lounge_chat_w", tostring(ow / W))
			end
			if (oh ~= me:GetTall()) then
				RunConsoleCommand("lounge_chat_h", tostring(oh / H))
			end
		end
	end
	frame.OldOnMouseReleased = frame.OnMouseReleased
	frame.OnMouseReleased = function(me, mc)
		me:OldOnMouseReleased(mc)

		if (mc == MOUSE_RIGHT) then
			me:ShowMenu()
		end
	end
	frame.ShowMenu = function(me)
		local menu = self.Menu()

			menu:AddOption(self.Lang("clear_chat"), function()
				RunConsoleCommand("lounge_chat_clear")
			end)

			menu:AddOption(self.Lang("chat_parsers"), function()
				self:ShowParsers()
			end)

			menu:AddOption(self.Lang("chat_options"), function()
				self:ShowOptions()
			end)

			menu:AddOption(self.Lang("reset_position"), function()
				RunConsoleCommand("lounge_chat_x", chat_x:GetDefault())
				RunConsoleCommand("lounge_chat_y", chat_y:GetDefault())
			end)

			menu:AddOption(self.Lang("reset_size"), function()
				RunConsoleCommand("lounge_chat_w", chat_w:GetDefault())
				RunConsoleCommand("lounge_chat_h", chat_h:GetDefault())
			end)

		menu:Open()
	end
	_LOUNGE_CHAT = frame

		local title = self.Label("", "LOUNGE_CHAT_16", self.Color("text"), frame)
		title:SetPaintedManually(true)
		title:AlignTop(11 - title:GetTall() * 0.5)
		title.x = title.y * 2
		title.Think = function(me)
			if (!self.ChatboxOpen) then
				return end

			if (!me.m_fNextRefresh or CurTime() >= me.m_fNextRefresh) then
				me.m_fNextRefresh = CurTime() + 1

				local t = self.ChatTitle
				t = t:Replace("%hostname%", GetHostName())
				t = t:Replace("%players%", self.Lang("players_online") .. ": " .. #player.GetAll() .. "/" .. game.MaxPlayers())
				t = t:Replace("%uptime%", self.Lang("server_uptime") .. ": " .. self.SecondsToEnglish(CurTime()))

				me:SetText(t)
				me:SizeToContentsX()
			end
		end
		frame.m_Title = title

		local close = vgui.Create("DButton", frame)
		close:SetPaintedManually(true)
		close:SetText("")
		close:SetSize(22, 22)
		close:AlignRight(0)
		close.Paint = function(me, w, h)
			if (me.Hovered) then
				draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("close_hover"), false, true, false, false)
			end

			if (me:IsDown()) then
				draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("hover"), false, true, false, false)
			end

			surface.SetDrawColor(me:IsDown() and self.Color("text_down") or self.Color("text"))
			surface.SetMaterial(matClose)
			surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 12 * scale, 12 * scale, 0)

			local b = chat_hide_options:GetBool()
			if (!b) then
				frame.m_Options:PaintManual()
			end
			frame.m_Options:SetMouseInputEnabled(!b)
		end
		close.DoClick = function(me)
			self:CloseChatbox()
		end
		frame.m_Close = close

		local options = vgui.Create("DButton", frame)
		options:SetPaintedManually(true)
		options:SetText("")
		options:SetSize(22, 22)
		options:MoveLeftOf(close)
		options.Paint = function(me, w, h)
			local c = self.Color("text")

			surface.SetDrawColor(c.r, c.g, c.b, c.a * (me.Hovered and 1 or 0.5))
			surface.SetMaterial(matOptions)
			surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 12 * scale, 12 * scale, 0)
		end
		options.DoClick = function(me)
			frame:ShowMenu()
		end
		frame.m_Options = options

		local history = vgui.Create("DScrollPanel", frame)
		self.PaintScroll(history)
		history:SetPaintedManually(true)
		history:Dock(FILL)
		history:DockMargin(0, 0, 0, 4)
		history.PerformLayout = function(me)
			local h = me.pnlCanvas:GetTall()
			local w = me:GetWide()
			local y = 0

			me:Rebuild()

			me.VBar:SetUp(me:GetTall(), me.pnlCanvas:GetTall())
			y = me.VBar:GetOffset()

			if (me.VBar.Enabled) then w = w - me.VBar:GetWide() end

			me.pnlCanvas:SetWide(w)

			me:Rebuild()
			if (h > me:GetTall()) then
				me.pnlCanvas:AlignTop(y)
			else
				me.pnlCanvas:AlignBottom(0)
			end

			if (h ~= me.pnlCanvas:GetTall()) then
				me.VBar:SetScroll(me.VBar:GetScroll()) -- Make sure we are not too far down!
			end
		end
		history.Rebuild = function(me)
			-- Rewrite this shit to take invisible els into account
			local cv = me:GetCanvas()
			local chi = cv:GetChildren()
			local h = 4

			for _, v in ipairs (chi) do
				h = h + v:GetTall()
			end

			cv:SetTall(h + (#chi > 0 and 4 or 0))
		end
		history.ScrollToBottom = function(me)
			me:PerformLayout()

			local vbar = me.VBar

			local anim = vbar:NewAnimation(self.Anims.FadeInTime)
			anim.StartPos = vbar.Scroll
			anim.TargetPos = vbar.CanvasSize
			anim.Think = function(anim, pnl, fraction)
				pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
			end
		end
		history.Think = function(me)
			local sc = me.VBar:GetScroll()
			frame.m_iScrollMin = sc
			frame.m_iScrollMax = sc + frame:GetTall()
		end
		history.Paint = function(me, w, h)
			if (self.ChatboxOpen) then
				local ci = self.Color("inbg")
				local a = frame.m_fAlpha or 255
				local af = frame.m_fAlphaFrac or 1

				draw.RoundedBox(4, 0, 0, w, h, Color(ci.r, ci.g, ci.b, ci.a * af))

				me.VBar:SetAlpha(a)
			else
				me.VBar:SetAlpha(0)
			end
		end
		frame.m_History = history

			history:InvalidateParent(true)
			history.pnlCanvas:DockPadding(4, 4, 4, 4)

		local bottom = vgui.Create("DPanel", frame)
		bottom:SetDrawBackground(false)
		bottom:Dock(BOTTOM)
		frame.m_Bottom = bottom

			local entry = vgui.Create("DTextEntry", bottom)
			entry:SetFont(self.ChatboxFont)
			entry:SetTextColor(self.Color("text"))
			entry:SetHighlightColor(self.Color("header"))
			entry:SetDrawLanguageID(false)
			entry:SetPaintedManually(true)
			entry:SetUpdateOnType(true)
			entry:Dock(FILL)
			entry.OldOnKeyCodeTyped = entry.OnKeyCodeTyped
			entry.Paint = function(me, w, h)
				draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("inbg"), true, false, true, false)
				me:DrawTextEntryText(me:GetTextColor(), me:GetHighlightColor(), me:GetTextColor())

				if (vgui.GetKeyboardFocus() == frame) then
					me:RequestFocus()
				end
			end
			entry.OnKeyCodeTyped = function(me, kc)
				if (kc == KEY_ESCAPE) then
					self:CloseChatbox()
				elseif (kc == KEY_TAB) then
					local str = hook.Call("OnChatTab", GAMEMODE, me:GetValue())
					if (str) then
						me:SetText(str)
					end
				elseif (kc == KEY_UP) then
					if (#self.History > 0) then
						if (!me.m_iCurPos) then
							me.m_iCurPos = #self.History
							me:SetText(self.History[me.m_iCurPos])
							me:SetCaretPos(me:GetText():len())
						elseif (me.m_iCurPos > 1) then
							me.m_iCurPos = me.m_iCurPos - 1
							me:SetText(self.History[me.m_iCurPos])
							me:SetCaretPos(me:GetText():len())
						end
					end
				elseif (kc == KEY_DOWN) then
					if (me.m_iCurPos and me.m_iCurPos < #self.History) then
						me.m_iCurPos = me.m_iCurPos + 1
						me:SetText(self.History[me.m_iCurPos])
						me:SetCaretPos(me:GetText():len())
					end
				end

				me:OldOnKeyCodeTyped(kc)
			end
			entry.OnValueChange = function(me, val)
				hook.Call("ChatTextChanged", GAMEMODE, val)
			end
			entry.OnEnter = function(me)
				local val = me:GetValue()
				if (val:Trim() ~= "") then
					local max = 126
					val = self.sub(val, 1, max)

					if (val:find('"')) then
						LocalPlayer():ConCommand((frame.m_bTeam and "say_team" or "say") .. " \"" .. val .. "\"")
					else
						RunConsoleCommand(frame.m_bTeam and "say_team" or "say"	, val)
					end
					table.insert(self.History, val)
				end

				self:CloseChatbox()
			end
			frame.m_Entry = entry

			local send = LOUNGE_CHAT.Button("send", bottom, function()
				entry:OnEnter()
			end)
			send:SetPaintedManually(true)
			send:Dock(RIGHT)
			send:DockMargin(4, 0, 0, 0)
			send.OldPaint = send.Paint
			send.Paint = function(me, w, h)
				me:OldPaint(w, h)
				frame.m_Emoticons:PaintManual()
			end
			frame.m_Send = send

			local emoticons = LOUNGE_CHAT.Button("", bottom, function()
				entry:OnEnter()
			end)
			emoticons:SetPaintedManually(true)
			emoticons:SetWide(bottom:GetTall())
			emoticons:Dock(RIGHT)
			emoticons.m_bHovering = false
			emoticons.m_fAlphaFrac = 40 / 255
			emoticons.m_fAlpha = 40
			emoticons.Paint = function(me, w, h)
				draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("inbg"), false, true, false, true)

				local b = me.Hovered or (IsValid(_LOUNGE_CHAT_EMOTICONS) and _LOUNGE_CHAT_EMOTICONS:IsVisible())
				if (b ~= me.m_bHovering) then
					me.m_bHovering = b

					me:Stop()
					local anim = me:NewAnimation(self.Anims.FadeInTime)
					anim.m_fStart = me.m_fAlpha
					anim.m_fTarget = b and 200 or 40
					anim.Think = function(anim, _, fraction)
						me.m_fAlphaFrac = fraction
						me.m_fAlpha = Lerp(fraction, anim.m_fStart, anim.m_fTarget)
					end
				end

				local c = self.Color("text")
				surface.SetDrawColor(c.r, c.g, c.b, me.m_fAlpha)
				surface.SetMaterial(matSmile)
				surface.DrawTexturedRectRotated(h * 0.5, h * 0.5, 14, 14, 0)
			end
			emoticons.DoClick = function()
				self:ShowEmoticons()
			end
			frame.m_Emoticons = emoticons

	self:ShowEmoticons()
end

function LOUNGE_CHAT:ShowParsers()
	if (IsValid(_LOUNGE_CHAT_PARSERS)) then
		_LOUNGE_CHAT_PARSERS:Remove()
	end

	local scale = math.Clamp(ScrH() / 1080, 0.7, 1)
	local wi, he = 500 * scale, 600 * scale

	local frame = vgui.Create("EditablePanel")
	frame:SetSize(wi, he)
	frame:Center()
	frame:MakePopup()
	frame.m_bF4Down = true
	frame.Think = function(me)
		if (input.IsKeyDown(KEY_ESCAPE)) then
			me:Close()

			gui.HideGameUI()
			timer.Simple(0, gui.HideGameUI)
		end
	end
	frame.Paint = function(me, w, h)
		draw.RoundedBox(4, 0, 0, w, h, self.Color("bg"))
	end
	frame.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, self.Anims.FadeOutTime, 0, function()
			me:Remove()
		end)
	end
	_LOUNGE_CHAT_PARSERS = frame

		local th = 48 * scale
		local m = th * 0.25
		local m5 = m * 0.5

		local header = vgui.Create("DPanel", frame)
		header:SetTall(th)
		header:Dock(TOP)
		header.Paint = function(me, w, h)
			draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("header"), true, true, false, false)
		end

			local title = self.Lang("chat_parsers")

			local titlelbl = self.Label(title, "LOUNGE_CHAT_24", self.Color("text"), header)
			titlelbl:Dock(LEFT)
			titlelbl:DockMargin(m, 0, 0, 0)

			local close = vgui.Create("DButton", header)
			close:SetText("")
			close:SetWide(th)
			close:Dock(RIGHT)
			close.Paint = function(me, w, h)
				if (me.Hovered) then
					draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("close_hover"), false, true, false, false)
				end

				if (me:IsDown()) then
					draw.RoundedBoxEx(4, 0, 0, w, h, self.Color("hover"), false, true, false, false)
				end

				surface.SetDrawColor(me:IsDown() and self.Color("text_down") or self.Color("text"))
				surface.SetMaterial(matClose)
				surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 16 * scale, 16 * scale, 0)
			end
			close.DoClick = function(me)
				frame:Close()
			end

		local body = vgui.Create("DScrollPanel", frame)
		self.PaintScroll(body)
		body:SetDrawBackground(false)
		body:DockMargin(m, m, m, m)
		body:GetCanvas():DockPadding(m5, m5, m5, m5)
		body:Dock(FILL)
		body.Paint = function(me, w, h)
			draw.RoundedBox(4, 0, 0, w, h, self.Color("inbg"))
		end

			for i, ex in ipairs (self.MarkupsExamples) do
				if (ex.perm) then
					local rest = self.MarkupsPermissions[ex.perm]
					if (rest) then
						local okay = false

						if (rest.usergroups and table.HasValue(rest.usergroups, LocalPlayer():GetUserGroup())) then
							okay = true
						elseif (rest.steamids) and (table.HasValue(rest.steamids, LocalPlayer():SteamID()) or table.HasValue(rest.steamids, LocalPlayer():SteamID64())) then
							okay = true
						end

						if (!okay) then
							continue end
					end
				end

				local pnl = vgui.Create("DButton", body)
				pnl:SetText("")
				pnl:SetSize(wi - m * 2 - m5 * 2, 80 * scale)
				pnl:Dock(TOP)
				pnl:DockPadding(m5, m5, m5, m5)
				pnl.Paint = function(me, w, h)
					draw.RoundedBox(4, 0, 0, w, h, self.Color("bg"))
				end
				pnl.DoClick = function()
					local ch = _LOUNGE_CHAT
					if (IsValid(ch) and IsValid(ch.m_Entry) and self.ChatboxOpen) then
						local tx = ch.m_Entry:GetValue() .. ex.example
						ch.m_Entry:SetText(tx)
						ch.m_Entry:SetCaretPos(tx:len())

						frame:Close()
					end
				end

					local lbl = self.Label(ex.tx, "LOUNGE_CHAT_16_B", self.Color("header"), pnl)
					lbl:Dock(TOP)
					lbl:DockMargin(0, 0, 0, m5)

					local lbl = self.Label(self.Lang("usage") .. ": " .. ex.example, "LOUNGE_CHAT_16", self.Color("text"), pnl)
					lbl:Dock(TOP)

					local parsed = self:ParseLineWrap({ex.example}, pnl:GetWide() - m5 * 2, pnl, LocalPlayer())
					parsed:Dock(TOP)
					parsed:SetMouseInputEnabled(false)

				pnl:InvalidateLayout(true)
				pnl:SizeToChildren(false, true)

				if (i > 1) then
					pnl:DockMargin(0, m5, 0, 0)
				end
			end

	frame:SetAlpha(0)
	frame:AlphaTo(255, self.Anims.FadeInTime)
end

concommand.Add("lounge_chat_parsers", function()
	LOUNGE_CHAT:ShowParsers()
end)

local function urlpaint(me, w, h)
	if (me.m_Image) then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(me.m_Image)
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function LOUNGE_CHAT:ShowEmoticons()
	local frame = _LOUNGE_CHAT
	local lx, ly = frame.m_Emoticons:LocalToScreen(0, 0)
	local x, y = frame:ScreenToLocal(lx, ly)

	local old = _LOUNGE_CHAT_EMOTICONS
	if (IsValid(old)) then
		if (old:IsVisible()) then
			old:Close()
		else
			old:SetPos(frame:GetWide() - old:GetWide() - 8, y - old:GetTall() - 8)
			old:SetVisible(true)
			old:SetAlpha(0)
			old:AlphaTo(255, self.Anims.FadeInTime)
			old.m_bClosing = false
		end

		return
	end

	local pnl = vgui.Create("DPanel", frame)
	pnl:SetSize(frame:GetWide() * 0.4, frame:GetTall() * 0.4)
	pnl:SetPos(frame:GetWide() - pnl:GetWide() - 8, y - pnl:GetTall() - 8)
	pnl.Paint = function(me, w, h)
		draw.RoundedBox(4, 0, 0, w, h, self.Color("bg"))
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, self.Anims.FadeOutTime, 0, function()
			me:SetVisible()
		end)
	end
	_LOUNGE_CHAT_EMOTICONS = pnl

		local scroll = vgui.Create("DScrollPanel", pnl)
		self.PaintScroll(scroll)
		scroll:Dock(FILL)
		scroll:DockMargin(4, 4, 4, 4)

			local ilist = vgui.Create("DIconLayout", scroll)
			ilist:Dock(FILL)

			for id, em in SortedPairs (self.Emoticons) do
				if (em.restrict) then
					local ok = false

					local rest = em.restrict
					if (rest.usergroups and table.HasValue(rest.usergroups, LocalPlayer():GetUserGroup())) then
						ok = true
					elseif (rest.steamids) and (table.HasValue(rest.steamids, LocalPlayer():SteamID()) or table.HasValue(rest.steamids, LocalPlayer():SteamID64())) then
						ok = true
					end

					if (!ok) then
						continue end
				end

				local img
				if (em.url) then
					img = vgui.Create("DButton", ilist)
					img:SetText("")
					img.Paint = urlpaint

					local mat = LOUNGE_CHAT.GetDownloadedImage(em.url)
					if (mat) then
						img.m_Image = mat
					else
						LOUNGE_CHAT.DownloadImage(
							em.url,
							function(mat)
								if (IsValid(img)) then
									img.m_Image = mat
								end
							end
						)
					end
				else
					img = vgui.Create("DImageButton", ilist)
					img:SetImage(em.path)
				end

				img:SetToolTip(":" .. id .. ":")
				img:SetSize(em.w, em.h)
				img.DoClick = function()
					if (IsValid(frame) and IsValid(frame.m_Entry)) then
						local tx = frame.m_Entry:GetValue() .. ":" .. id .. ":"
						frame.m_Entry:SetText(tx)
						frame.m_Entry:SetCaretPos(tx:len())

						pnl:Close()
					end
				end
			end

	pnl:SetAlpha(0)
	pnl:AlphaTo(255, self.Anims.FadeInTime)

	return pnl
end

function LOUNGE_CHAT:SplitLine(tx, fnt, maxwi, cont, i)
	-- Check where to split line for 1 single word bigger than the remaining space
	-- (retards spamming "aaaaaaaaaaaa")
	surface.SetFont(fnt)
	local sw = surface.GetTextSize(tx)
	if (sw >= maxwi) then
		local s = ""

		if (self.UseUTF8) then
			tx = utf8.force(tx)

			for p, c in utf8.codes(tx) do
				local n = s .. utf8.char(c)

				local sw2 = surface.GetTextSize(n)
				if (sw2 >= maxwi) then
					s = self.sub(n, 1, -3)
					table.insert(cont, i + 1, self.sub(tx, s:len() + 1))

					cont[i] = s
					return s
				else
					s = n
				end
			end
		else
			for j = 1, #tx do
				local n = s .. tx[j]

				local sw2 = surface.GetTextSize(n)
				if (sw2 >= maxwi) then
					s = string.sub(n, 1, -3)
					table.insert(cont, i + 1, tx:sub(s:len() + 1))

					cont[i] = s
					return s
				else
					s = n
				end
			end
		end
	end

	-- Check where to split line for spaced words
	local sw = surface.GetTextSize(" ")

	local expl = string.Explode(" ", tx)

	local line = {}
	local w = 0

	for id, wo in pairs (expl) do
		local _w, _h = surface.GetTextSize(wo)
		if (id == 1 or w + _w < maxwi) then
			w = w + _w + sw
			table.insert(line, wo)
		else
			table.insert(cont, i + 1, table.concat(expl, " ", id))
			break
		end
	end

	cont[i] = table.concat(line, " ")
	return cont[i]
end

function LOUNGE_CHAT:ParseMarkups(parent, sender, tx, defaultfont, defaultcolor, maxwi, cont, i, bypass, underline)
	local parsed = false
	for _, mup in ipairs (self.ChatMarkups) do
		local d = {string.find(tx, mup.match)}
		local s, e = d[1], d[2]
		if (s) then
			local okay = true

			if (mup.perm and IsValid(sender) and !bypass) then
				local rest = self.MarkupsPermissions[mup.perm]
				if (rest) then
					okay = false

					if (rest.usergroups and table.HasValue(rest.usergroups, sender:GetUserGroup())) then
						okay = true
					elseif (rest.steamids) and (table.HasValue(rest.steamids, sender:SteamID()) or table.HasValue(rest.steamids, sender:SteamID64())) then
						okay = true
					end
				end
			end

			if (okay) then
				table.remove(d, 1)
				table.remove(d, 1)

				parsed = true
				cont[i] = ""

				local before = self.sub(tx, 1, s - 1)
				local after = self.sub(tx, e + 1)
				if (before ~= "") then
					table.insert(cont, i + 1, before)
					i = i + 1
				end

				local res = mup.func({parent = parent, sender = sender, args = d, text = self.sub(tx, s, e), defaultfont = defaultfont, defaultcolor = defaultcolor, underline = underline, maxwi = maxwi, cont = cont, i = i})
				if (res) then
					if (istable(res) and !res.r) then
						for __, v in pairs (res) do
							table.insert(cont, i + 1, v)
							i = i + 1
						end
					else
						table.insert(cont, i + 1, res)
						i = i + 1
					end
				end

				if (after ~= "") then
					table.insert(cont, i + 1, after)
				end
			end

			break
		end
	end

	if (parsed) then
		return nil
	else
		return tx
	end
end

local messagequeue = {}

function LOUNGE_CHAT:MakeChatLabel(tx, font, color, parent, underline)
	local ele = self.Label(tx, font, color, parent)
	ele:SetExpensiveShadow(1, color_black)
	ele:SetWide(ele:GetWide() + 1)

	if (underline) then
		ele.Paint = function(me, w, h)
			LOUNGE_CHAT.UnderlinePaint(me, w, h)
		end
	end

	return ele
end

function LOUNGE_CHAT.UnderlinePaint(me, w, h)
	surface.SetDrawColor(me:GetTextColor())
	surface.DrawRect(0, h - 2, w, 1)
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(1, h - 1, w - 2, 1)
end

function LOUNGE_CHAT:ParseLineWrap(cont, maxwi, parent, sender)
	if (maxwi == true) then
		if (IsValid(_LOUNGE_CHAT)) then
			maxwi = _LOUNGE_CHAT.m_History:GetWide() - 24
		else
			if (!IsValid(LocalPlayer())) then
				table.insert(messagequeue, {
					cont = cont,
					maxwi = maxwi,
					parent = parent,
					sender = sender,
				})

				return
			end

			maxwi = 100 -- que
		end
	end

	local origtext = ""

	local line = vgui.Create("DPanel", parent)
	line:SetDrawBackground(false)
	line.Paint = nopaint
	line.OnMousePressed = function(me, mc)
		if (mc == MOUSE_RIGHT) then
			me:ShowMenu()
		end
	end
	line.ShowMenu = function(me, add)
		local menu = self.Menu()

			menu:AddOption(self.Lang("copy_message"), function()
				SetClipboardText(origtext)
			end)

			if (add) then
				for _, v in pairs (add) do
					menu:AddOption(self.Lang(v.text), function()
						v.func()
					end)
				end
			end

		menu:Open()
	end

		local contents = vgui.Create("DPanel", line)
		contents:Dock(FILL)
		contents:SetDrawBackground(false)
		contents.Paint = nopaint
		contents.OnMousePressed = function(me, mc)
			line:OnMousePressed(mc)
		end
		line.m_Contents = contents

	local bx = 0
	local x, y, w, lh = 0, 0, 0, 0
	local h = 0
	local nl = false
	local inline = {}

	local defaultfont = self.ChatboxFont
	local defaultcolor = color_white
	local noparse = false
	local bypassperm = false
	local underline = false
	local url, lua
	local urlbtns, luabtns = {}, {}

	local function urlpaint(me, w, h)
		local b = false
		for _, v in ipairs (me.m_Buttons) do
			if (IsValid(v) and v.Hovered) then
				b = true
				break
			end
		end

		me:SetTextColor(b and LOUNGE_CHAT.Color("url_hover") or LOUNGE_CHAT.Color("url"))

		LOUNGE_CHAT.UnderlinePaint(me, w, h)
	end

	local pre

	local tries = 0
	for i, el in pairs (cont) do
		tries = tries + 1
		if (tries > 512) then
			line:Remove()
			error("overflow!! (this shouldn't happen, report this to the author with the message)")
			return
		end

		local ele, forcebreak

		if (isstring(el) or isnumber(el)) then
			if (el == "") then
				continue end

			el = (noparse or url) and el or self:ParseMarkups(contents, sender, el, defaultfont, defaultcolor, maxwi - x, cont, i, bypassperm, underline)

			if (maxwi and el and el ~= "") then
				surface.SetFont(defaultfont)
				local _w, _h = surface.GetTextSize(el)
				if (_w > maxwi - x) then -- This string is gonna be too long, we need to split it!!
					el = self:SplitLine(el, defaultfont, maxwi - x, cont, i)
					if (el == "") then
						nl = true
					end
				end
			end

			if (el and el ~= "") then
				if (#inline == 0) then
					el = el:TrimLeft()
				end

				ele = self:MakeChatLabel(el, defaultfont, defaultcolor, contents, underline)

				if (url and url ~= "") then
					ele:SetMouseInputEnabled(true)
					ele:SetWide(ele:GetWide() + 1)
					ele:SetTall(ele:GetTall() + 2)
					ele.Paint = urlpaint
					ele.m_URL = url

						local realurl = ele.m_URL:Trim()

						local btn = vgui.Create("DButton", ele)
						btn:SetToolTip(realurl)
						btn:SetText("")
						btn:Dock(FILL)
						btn.Paint = function() end
						btn.DoClick = function(me)
							gui.OpenURL(realurl)
						end
						btn.DoRightClick = function(me)
							line:ShowMenu({
								{text = "copy_url", func = function()
									SetClipboardText(realurl)
								end}
							})
						end
						ele.m_Button = btn

					table.insert(urlbtns, btn)
					ele.m_Buttons = urlbtns
				end
			end
		elseif (istable(el)) then
			if (el.r) then
				defaultcolor = el
			elseif (el.font) then
				defaultfont = el.font
			elseif (el.linebreak) then
				forcebreak = true
			elseif (el.noparse ~= nil) then
				noparse = el.noparse
			elseif (el.bypass ~= nil) then
				bypassperm = el.bypass
			elseif (el.pre and i == 1) then
				ele = el.pre
				ele:SetParent(contents)
				pre = ele

				bx = bx + ele:GetWide() + (el.space or 0)
			elseif (el.url ~= nil) then
				url = el.url

				if (url == false) then
					for _, v in ipairs (urlbtns) do
						if (IsValid(v)) then
							v.m_Buttons = table.Copy(urlbtns)
						end
					end

					urlbtns = {}
				end
			elseif (el.origtext) then
				origtext = el.origtext
			elseif (el.lua ~= nil) then
				lua = el

				if (el.lua == false) then
					for _, v in ipairs (luabtns) do
						if (IsValid(v)) then
							v.m_Buttons = table.Copy(luabtns)
						end
					end

					luabtns = {}
					lua = nil
				end
			elseif (el.underline ~= nil) then
				underline = el.underline
			end
		elseif (IsPlayer(el)) then
			local coltouse = team.GetColor(el:Team())
			if (ROLE_DETECTIVE and el.IsActiveDetective and el:IsActiveDetective()) then
				coltouse = Color(50, 200, 255)
			end

			ele = self:MakeChatLabel(el:Nick(), defaultfont, coltouse, contents)
		elseif (ispanel(el)) then
			ele = el
		end

		if (lua and ispanel(ele) and IsValid(ele)) then
			local func = lua.lua

			ele:SetMouseInputEnabled(true)
			ele:SetCursor("user")
			ele.m_Lua = lua

				local btn = vgui.Create("DButton", ele)
				btn:SetText("")
				btn:Dock(FILL)
				btn.Paint = function() end
				btn.DoClick = function(me)
					func()
				end
				btn.DoRightClick = function(me)
					line:ShowMenu()
				end
				ele.m_Button = btn

				if (lua.hover) then
					btn.OnCursorEntered = function(me)
						func()
					end
				end
		end

		local function newl()
			if (lh == 0) then
				lh = draw.GetFontHeight(defaultfont)
			end

			x = bx
			h = h + lh
			y = y + lh
			lh = 0
			inline = {}
		end

		if (IsValid(ele)) then
			local wi, he = ele:GetWide(), ele:GetTall()
			if (i == 1 and bx > 0) then
				wi = math.max(wi, bx)
			end

			if (x + wi > maxwi) then
				newl()
			end

			if (he > lh) then
				lh = he

				-- center vertically all prior elements in the line to take in account the new line height
				for _, v in ipairs (inline) do
					v:AlignTop(y + lh * 0.5 - v:GetTall() * 0.5)
				end
			end

			if (ele:GetName() ~= "DButton") then
				ele.OnMousePressed = function(me, mc)
					line:OnMousePressed(mc)
				end
			end

			ele:SetPos(x, y + lh * 0.5 - he * 0.5)
			x = x + wi
			w = x
			table.insert(inline, ele)
		end

		if (nl or forcebreak) then
			newl()
			nl = false
			forcebreak = false
		end
	end

	if (lh > 0) then
		h = h + lh
	end

	line:SetSize(w, h)

	return line
end

function LOUNGE_CHAT:AddToChatbox(el)
	if (!IsValid(_LOUNGE_CHAT)) then
		return end

	--
	el:SetAlpha(0)
	el:AlphaTo(255, self.Anims.FadeInTime)

	el.m_fLastVisible = RealTime()
	el.Think = function(me)
		-- Dynvis
		local sc = _LOUNGE_CHAT.m_iScrollMin
		local sc2 = _LOUNGE_CHAT.m_iScrollMax

		local a, b = me.y, me.y + me:GetTall()
		me.m_Contents:SetVisible((a >= sc and a <= sc2) or (b >= sc and b <= sc2))

		-- fadeout
		local rt = RealTime()
		if (!self.ChatboxOpen) then
			if (rt - me.m_fLastVisible >= chat_message_hidetime_cache and !me.m_bFading) then
				me.m_bFading = true
				me:AlphaTo(0, self.Anims.TextFadeOutTime)
			end
		else
			me.m_bFading = nil
			me.m_fLastVisible = rt
			me:Stop()
			me:SetAlpha(255)
		end
	end

	local his = _LOUNGE_CHAT.m_History
	local can = his:GetCanvas()

	if (self.MaxMessages > 0 and #can:GetChildren() > self.MaxMessages) then
		local i = 0
		while (#can:GetChildren() - i > self.MaxMessages) do
			local child = can:GetChild(i)
			if (IsValid(child)) then
				child:Remove()
				i = i + 1
			else
				break
			end
		end
	end

	his:AddItem(el)
	el:Dock(TOP)
	-- no
	can:SetTall(can:GetTall() + el:GetTall())
	his.VBar:SetUp(his:GetTall(), can:GetTall())

	if not (self.ChatboxOpen and chat_no_scroll_while_open:GetBool()) then
		-- his.VBar:SetScroll(can:GetTall() + el:GetTall())
		his:GetCanvas():InvalidateLayout(true)
		timer.Simple(0, function()
			if (!IsValid(his) or !IsValid(el)) then
				return end

			his:ScrollToBottom()
		end)
	end

	chat.PlaySound()

	return el
end

function LOUNGE_CHAT:OpenChatbox(bteam)
	if (self.ChatboxOpen) then
		return end

	hook.Call("StartChat", GAMEMODE, bteam)

	if (!IsValid(_LOUNGE_CHAT)) then
		self:CreateChatbox()
	end
	if (IsValid(_LOUNGE_CHAT_EMOTICONS)) then
		_LOUNGE_CHAT_EMOTICONS:SetVisible(false)
	end

	-- Fade in
	_LOUNGE_CHAT.m_fAlpha = 0
	_LOUNGE_CHAT:Stop()
	_LOUNGE_CHAT:NewAnimation(self.Anims.FadeInTime).Think = function(anim, me, frac)
		me.m_fAlpha = 255 * frac
	end

	--
	_LOUNGE_CHAT:MakePopup()

	_LOUNGE_CHAT.m_Entry.m_iCurPos = nil
	_LOUNGE_CHAT.m_Entry:RequestFocus()

	if (ROLE_TRAITOR and LocalPlayer().IsSpecial and !LocalPlayer():IsSpecial()) then
		bteam = false
	end
	_LOUNGE_CHAT.m_bTeam = bteam

	self.ChatboxOpen = true

	net.Start("LOUNGE_CHAT.Typing")
		net.WriteBool(true)
	net.SendToServer()
end

function LOUNGE_CHAT:CloseChatbox()
	if (IsValid(_LOUNGE_CHAT_EMOTICONS)) then
		_LOUNGE_CHAT_EMOTICONS:Close()
	end

	self.ChatboxOpen = false

	net.Start("LOUNGE_CHAT.Typing")
		net.WriteBool(false)
	net.SendToServer()

	hook.Call("ChatTextChanged", GAMEMODE, "")
	hook.Call("FinishChat", GAMEMODE)

	-- Fade out
	local a = _LOUNGE_CHAT.m_fAlpha or 255

	_LOUNGE_CHAT:Stop()
	_LOUNGE_CHAT:NewAnimation(self.Anims.FadeOutTime * (a / 255)).Think = function(anim, me, frac)
		me.m_fAlpha = a * (1 - frac)
	end

	--
	_LOUNGE_CHAT:SetKeyboardInputEnabled(false)
	_LOUNGE_CHAT:SetMouseInputEnabled(false)

	_LOUNGE_CHAT.m_Entry:SetText("")
end

chat.OldGetChatBoxPos = chat.OldGetChatBoxPos or chat.GetChatBoxPos
chat.OldGetChatBoxSize = chat.OldGetChatBoxSize or chat.GetChatBoxSize
chat.OldAddText = chat.OldAddText or chat.AddText

function chat.GetChatBoxPos()
	if (IsValid(_LOUNGE_CHAT)) then
		return _LOUNGE_CHAT:GetPos()
	else
		return chat.OldGetChatBoxPos()
	end
end

function chat.GetChatBoxSize()
	if (IsValid(_LOUNGE_CHAT)) then
		return _LOUNGE_CHAT:GetSize()
	else
		return chat.OldGetChatBoxSize()
	end
end

function chat.AddText(...)
	local args = {...}

	local t = {}
	for _, v in pairs (args) do
		if (isstring(v)) then
			table.insert(t, v)
		end
	end
	local origtext = table.concat(t, "")
	table.insert(args, {origtext = origtext})

	chat.OldAddText(...)
	LOUNGE_CHAT:AddToChatbox(LOUNGE_CHAT:ParseLineWrap(args, true))
end

concommand.Add("lounge_chat_clear", function()
	_LOUNGE_CHAT.m_History:Clear()
end)

local con = {}
local tab = {}
local function Add(el, console, i)
	if (istable(el) and #el > 1) then
		table.Add(tab, el)
	else
		if (i) then
			table.insert(tab, i, el)
		else
			table.insert(tab, el)
		end
	end

	if (console) then
		if (istable(el) and !el.r) then
			table.Add(con, el)
		else
			if (i) then
				table.insert(con, i, el)
			else
				table.insert(con, el)
			end
		end
	end
end

-- this is terrible and should be rewritten
function LOUNGE_CHAT:OnPlayerChat(ply, text, bteam, bdead, preftext, prefcolor, color)
	con = {}
	tab = {}

	Add({bypass = true})

	local textcol = color_white
	local namecol = IsValid(ply) and team.GetColor(ply:Team()) or color_white

	if (IsValid(ply)) then
		local ccp = self.CustomColorsPlayers[ply:SteamID()] or self.CustomColorsPlayers[ply:SteamID64()]
		local ccu = self.CustomColorsGroups[ply:GetUserGroup()]
		namecol = ccp or ccu or namecol
	end

	-- (shitty) dayz tags
	if (engine.ActiveGamemode() == "dayz") or (DrawHPImage and DrawAmmoInfo) then
		local sign = text:sub(1, 1)
		if (self.DayZ_ChatTags[sign]) then
			local fs = string.find(text, " ")
			if (fs) then
				local cmd = self.sub(text, 2, fs - 1)
				local tag = self.DayZ_ChatTags[sign][cmd]
				if (tag) then
					Add({tag.tagcolor, tag.tag}, true)
					text = self.sub(text, fs + 1)
				end
			end
		end
	end

	if (IsValid(ply)) then
		-- customtags
		if (ATAG) then
			local pieces, messageColor, nameColor = ply:getChatTag()
			if (pieces) then
				for _, p in pairs (pieces) do
					Add({p.color, p.name})

					if (!nameColor) then
						namecol = p.color
					end
				end

				namecol = nameColor or namecol
				textcol = messageColor or textcol
			end
		elseif (self.EnableCustomTags) then
			local ct = self.CustomTagsPlayers[ply:SteamID()] or self.CustomTagsPlayers[ply:SteamID64()]
			if (ct) then
				Add(ct)
			else
				ct = self.CustomTagsGroups[ply:GetUserGroup()]
				if (ct) then
					Add(ct)
				end
			end
		end

		-- TeamTags
		if (self.TeamTags) then
			local t = ply:Team()

			local tx = string.format(self.TeamTagsFormat, team.GetName(t))
			if (self.TeamTagsCase == 1) then
				tx = tx:upper()
			elseif (self.TeamTagsCase == -1) then
				tx = tx:lower()
			end

			Add({
				team.GetColor(t),
				tx
			})
		end

		if (!self.ProfanityBypass[ply:GetUserGroup()]) then
			for _, word in pairs (self.ProfanityFilter) do
				local tries = 0
				local s, e = string.find(text:lower(), word)
				while (s and tries <= 128) do
					text = text:sub(1, s - 1) .. string.rep(self.CensorCharacter, e - s + 1) .. text:sub(e + 1)
					tries = tries + 1
					s, e = string.find(text, word)
				end
			end
		end
	end

	-- TTT detective color
	if (IsValid(ply) and ROLE_DETECTIVE and ply.IsActiveDetective and ply:IsActiveDetective()) then
		namecol = Color(50, 200, 255)
	end

	if (bdead) then
		Add(self.TagDead)
		table.Add(con, self.TagDeadConsole)
	end

	if (bteam) then
		if (ROLE_TRAITOR and LocalPlayer().IsSpecial and !LocalPlayer():IsSpecial()) then
			bteam = false
		end

		if (bteam == true and IsValid(ply)) then
			Add({team.GetColor(ply:Team()), self.TagTeam})

			table.insert(con, team.GetColor(ply:Team()))
			table.Add(con, self.TagTeamConsole)
		elseif (istable(bteam) and bteam.color and bteam.text) then
			Add({bteam.color, bteam.text}, true)
		end
	end

	-- should be darkrp
	local darkrp = DarkRP and preftext and prefcolor and color
	if (darkrp) then
		if (preftext) then
			Add({prefcolor, preftext})
			textcol = messageColor or color
		end
	end

	if (IsValid(ply)) then
		if (self.ShowPlayerAvatar and !GetConVar("lounge_chat_hide_avatars"):GetBool()) then
			local av = self:Avatar(ply)
			av.m_bMessageAvatar = true

			Add({
				pre = av,
				space = 4,
			}, false, 1)
		end
	end

	local ts = chat_timestamps:GetBool()
	if (ts) then
		table.insert(con, 1, "[" .. self.Timestamp() .. "] ")
		table.insert(con, 1, self.Color("timestamp"))
	end

	if (self.MessageStyle == 0 and ts) then
		Add("<timestamp=" .. os.time() .. "> - ", nil, 2)
	end

	if (darkrp) then
		table.insert(con, prefcolor)
		table.insert(con, preftext)
		table.insert(con, textcol)
		table.insert(con, ": " .. text)
	else
		if (IsValid(ply)) then
			if (self.DisallowParsersInName) then
				Add({namecol, {noparse = true}, ply:Nick(), {noparse = false}}, true)
			else
				Add({namecol, ply:Nick()}, true)
			end
		else
			Add(self.ConsoleName, true)
		end
	end

	if (self.MessageStyle == 1) then
		if (ts) then
			Add({textcol, " - <timestamp=" .. os.time() .. ">"}, nil, 2)
		end

		Add({linebreak = true})
	end

	Add({bypass = false})

	Add({textcol, (self.MessageStyle == 1 and "" or ": ") .. text})
	if (!darkrp) then
		table.Add(con, {textcol, ": " .. text})
	end

	-- console friendly message
	chat.OldAddText(unpack(con))

	-- actual message
	table.insert(tab, {origtext = text})
	self:AddToChatbox(self:ParseLineWrap(tab, true, nil, ply))
end

-- for developers. The text is not styled so you will have to do that yourself
-- The func is called when the player clicks on the message label
-- set hover to true to trigger the func on text hover
function LOUNGE_CHAT:AddLuaMessage(text, func, hover)
	local tab = {
		{origtext = text},
		{lua = func, hover = hover or false},
		text,
		{lua = false},
	}

	self:AddToChatbox(self:ParseLineWrap(tab, true, nil, ply))
end

LOUNGE_CHAT.LuaButtons = {}

function LOUNGE_CHAT:MakeLuaButton(text, func, hover)
	local i = #self.LuaButtons + 1
	self.LuaButtons[i] = func

	return "<luabtn=" .. i .. "," .. (hover and 1 or 0) .. ">" .. text .. "</luabtn>"
end

hook.Add("OnPlayerChat", "LOUNGE_CHAT.OnPlayerChat", function(ply, text, bteam, bdead, preftext, prefcolor, color)
	LOUNGE_CHAT:OnPlayerChat(ply, text, bteam, bdead, preftext, prefcolor, color)
	return true
end)

hook.Add("PlayerBindPress", "LOUNGE_CHAT.PlayerBindPress", function(ply, bind, press)
	if (bind:find("messagemode")) then
		LOUNGE_CHAT:OpenChatbox(bind:find("messagemode2"))
		return true
	end
end)

hook.Add("ChatText", "LOUNGE_CHAT.ChatText", function(index, name, text, typ)
	if (index ~= 0) then
		return end

	chat.AddText(text)
end)

hook.Add("HUDShouldDraw", "LOUNGE_CHAT.HUDShouldDraw", function(h)
	if (h == "CHudChat") then
		return false
	end
end)

LOUNGE_CHAT:CreateChatboxFonts()

hook.Add("InitPostEntity", "LOUNGE_CHAT.InitPostEntity", function()
	-- "Load twice because apparently once is not enough"
	LOUNGE_CHAT:CreateChatboxFonts()
end)

hook.Add("Think", "LOUNGE_CHAT.Think", function()
	if (IsValid(LocalPlayer())) then
		hook.Remove("Think", "LOUNGE_CHAT.Think")
		hook.Remove("OnPlayerChat", "ATAG_ChatTags")

		LOUNGE_CHAT:CreateChatbox()

		for _, v in pairs (messagequeue) do
			LOUNGE_CHAT:AddToChatbox(LOUNGE_CHAT:ParseLineWrap(v.cont, v.maxwi, v.parent, v.sender))
		end

		-- TTT override
		if (ROLE_TRAITOR) then
			net.Receive("TTT_RoleChat", LOUNGE_CHAT.TTT_RoleChat)
			net.Receive("TTT_LastWordsMsg", LOUNGE_CHAT.TTT_LastWordsMsg)
		end
	end
end)

-- shitty override for a shitty gamemode
net.Receive("LOUNGE_CHAT.TTTRadio", function()
	local sender = net.ReadEntity()
	local msg = net.ReadString()
	local param = net.ReadString()
	if not (IsValid(sender) and sender:IsPlayer()) then
		return end

	GAMEMODE:PlayerSentRadioCommand(sender, msg, param)

	-- if param is a language string, translate it
	-- else it's a nickname
	local lang_param = LANG.GetNameParam(param)
	if (lang_param) then
		if lang_param == "quick_corpse_id" then
			-- special case where nested translation is needed
			param = LANG.GetParamTranslation(lang_param, {player = net.ReadString()})
		else
			param = LANG.GetTranslation(lang_param)
		end
	end

	local text = LANG.GetParamTranslation(msg, {player = param})

	-- don't want to capitalize nicks, but everything else is fair game
	if (lang_param) then
		text = util.Capitalize(text)
	end

	if (sender:IsDetective()) then
		LOUNGE_CHAT:OnPlayerChat(
			sender,
			text,
			{
				color = Color(20, 100, 255),
				text = Format("(%s) ", string.upper(LANG.GetTranslation("detective")))
			},
			false
		)
	else
		LOUNGE_CHAT:OnPlayerChat(sender, text, false, false)
	end
end)

function LOUNGE_CHAT.TTT_RoleChat()
	local role = net.ReadUInt(2)
	local sender = net.ReadEntity()
	if not (IsValid(sender)) then
		return end

	local text = net.ReadString()

	if (role == ROLE_TRAITOR) then
		LOUNGE_CHAT:OnPlayerChat(
			sender,
			text,
			{
				color = Color(255, 30, 40),
				text = Format("(%s) ", string.upper(LANG.GetTranslation("traitor")))
			},
			false
		)
	elseif (role == ROLE_DETECTIVE) then
		LOUNGE_CHAT:OnPlayerChat(
			sender,
			text,
			{
				color = Color(20, 100, 255),
				text = Format("(%s) ", string.upper(LANG.GetTranslation("detective")))
			},
			false
		)
	end
end

function LOUNGE_CHAT.TTT_LastWordsMsg()
	local sender = net.ReadEntity()
	if not (IsValid(sender)) then
		return end

	local text = net.ReadString()

	LOUNGE_CHAT:OnPlayerChat(
		sender,
		text,
		{
			color = Color(150, 150, 150),
			text = Format("(%s) ", string.upper(LANG.GetTranslation("last_words"))),
		},
		false
	)
end