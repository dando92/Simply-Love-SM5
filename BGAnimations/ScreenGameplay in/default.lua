-- code for setting the PlayerOptions string (needed to counteract ITG mod charts)
-- and the MeasureCounter has been abstracted out to a different file to keep this one simpler.
local InitializeMeasureCounterAndModsLevel = LoadActor("./MeasureCounterAndModsLevel.lua")

local text = ""
local SongNumberInCourse = 0
local SongsInCourse
local style = ThemePrefs.Get("VisualStyle")
local assets = {
	splode     = THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn splode"),
	minisplode = THEME:GetPathG("", "_VisualStyles/"..style.."/GameplayIn minisplode")
}

if IsSpooky() then
	assets.splode     = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
	assets.minisplode = THEME:GetPathG("", "_VisualStyles/Spooky/ExtraSpooky/Bats")
end

if GAMESTATE:IsCourseMode() then
	SongsInCourse = #GAMESTATE:GetCurrentCourse():GetCourseEntries()
	text = ("%s 1 / %d"):format(THEME:GetString("Stage", "Stage"), SongsInCourse)

elseif not PREFSMAN:GetPreference("EventMode") then
	text = THEME:GetString("Stage", "Stage") .. " " .. tostring(SL.Global.Stages.PlayedThisGame + 1)

else
	text = THEME:GetString("Stage", "Event")
end

InitializeMeasureCounterAndModsLevel(SongNumberInCourse)

-------------------------------------------------------------------------

local af = Def.ActorFrame{}

af[#af+1] = Def.ActorFrame{
	-- no need to keep drawing these during gameplay; set visible(false) once they're done and save a few clock cycles
	OnCommand=function(self)
		if SL.Global.GameplayReloadCheck then
			-- don't bother animating these visuals if ScreenGameplay was just reloaded by a mod chart
			-- just jump directly to hiding this lead in
			self:playcommand("Hide")
		else
			self:sleep(2):queuecommand("Hide")
		end
	end,
	HideCommand=function(self)
		self:visible(false)
		SL.Global.GameplayReloadCheck = true
	end,
	OffCommand=function(self)
		SL.Global.GameplayReloadCheck = false
	end,

	Def.Quad{
		InitCommand=function(self) self:diffuse(Color.Black):Center():FullScreen() end,
		OnCommand=function(self) self:sleep(1.4):accelerate(0.6):diffusealpha(0) end
	},

	LoadActor(assets.splode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationz(10):zoom(0):diffusealpha(0.9) end,
		OnCommand=function(self) self:sleep(0.4):linear(0.6):rotationz(0):zoom(1.1):diffusealpha(0) end
	},
	LoadActor(assets.splode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationy(180):rotationz(-10):zoom(0):diffusealpha(0.8) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.6):rotationz(0):zoom(1.3):diffusealpha(0) end
	},
	LoadActor(assets.minisplode)..{
		InitCommand=function(self) self:diffuse(GetCurrentColor(true)):Center():rotationz(10):zoom(0) end,
		OnCommand=function(self) self:sleep(0.4):decelerate(0.8):rotationz(0):zoom(0.9):diffusealpha(0) end
	}
}

for player in ivalues(GAMESTATE:GetHumanPlayers()) do
	af[#af+1] = LoadFont("Common Normal")..{
		Text=PlayerModifiersString(player),
		InitCommand=function(self)
			self:y(_screen.h - 20):valign(1)

			if player == PLAYER_1 then
				self:x(20):halign(0)
			else
				self:x(_screen.w - 20):halign(1)
			end
		end,
		OnCommand=function(self)
			self:diffusealpha(1):sleep(1):accelerate(0.33):diffusealpha(0)
		end,
	}
end

af[#af+1] = LoadFont("Common Bold")..{
	Text=text,
	InitCommand=function(self) self:Center():diffusealpha(0):shadowlength(1) end,
	OnCommand=function(self)
		-- don't animate the text tweening to the bottom of the screen if ScreenGameplay was just reloaded by a mod chart
		if not SL.Global.GameplayReloadCheck then
			self:accelerate(0.5):diffusealpha(1):sleep(0.66):accelerate(0.33)
		end
		self:zoom(0.4):y(_screen.h-30)

		-- offset "stage i" text to the left or right if only one player is joined, and that player's notefield is centered
		if #GAMESTATE:GetHumanPlayers() == 1 and GetNotefieldX( GAMESTATE:GetMasterPlayerNumber() ) == _screen.cx then
			local player = GAMESTATE:GetHumanPlayers()[1]
			self:x(_screen.cx + (GetNotefieldWidth()*0.5 + self:GetWidth()*0.25) * (player==PLAYER_1 and -1 or 1))
		end
	end,
	CurrentSongChangedMessageCommand=function(self)
		if GAMESTATE:IsCourseMode() then
			InitializeMeasureCounterAndModsLevel(SongNumberInCourse)
			SongNumberInCourse = SongNumberInCourse + 1
			self:settext(("%s %d / %d"):format(THEME:GetString("Stage", "Stage"), SongNumberInCourse, SongsInCourse))
		end
	end
}

return af