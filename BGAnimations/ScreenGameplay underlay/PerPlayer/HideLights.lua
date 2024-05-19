local player = ...
local pn = ToEnumShortString(player)
local mods = SL[pn].ActiveModifiers

return Def.ActorFrame{
    OnCommand=function(self)
        if mods.HideLights then         
            local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
            
            playeroptions["HideLights"](playeroptions, mods.HideLights)
        end
    end,
    OffCommand=function(self)
        if mods.HideLights then
            local playeroptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")

            playeroptions["HideLights"](playeroptions, false)
        end
    end
}
