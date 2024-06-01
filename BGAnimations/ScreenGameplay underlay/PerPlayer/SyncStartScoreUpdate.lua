local player = ...
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

return Def.Actor{
	JudgmentMessageCommand=function(self)
		self:queuecommand("PropagateScore")
	end,
	PropagateScoreCommand=function(self)
		if SYNCMAN and SYNCMAN:IsEnabled() then
			if ThemePrefs.Get("ScoringSystem") == "ITG" then
				local dance_points = pss:GetPercentDancePoints()
				local percent = FormatPercentScore( dance_points ):sub(1,-2)

				SYNCMAN:BroadcastScoreChange(pss, percent, 0, pss:GetActualDancePoints(), pss:GetPossibleDancePoints())
			end	
		end
	end,
	ExCountsChangedMessageCommand=function(self, params)
		if SYNCMAN and SYNCMAN:IsEnabled() then
			if ThemePrefs.Get("ScoringSystem") == "EX" then
				local ex_counts = SL[ToEnumShortString(player)].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].ex_counts
				local white_count = ex_counts["W1"]
				SYNCMAN:BroadcastScoreChange(pss, params.ExScore, white_count, params.ActualPoints, params.ActualPossible)
			end	
        end
	end,
}