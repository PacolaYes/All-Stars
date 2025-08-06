
-- who needs to play coop
-- when you can play coop
-- -pac

Squigglepants.addGametype({
	name = "RACE",
	identifier = "RACE",
	description = "race",
	exclusive = false,
	typeoflevel = TOL_RACE,
    hud = "AS-raceMain"
})

local voteScreen = Squigglepants.voteScreen

addHook("ThinkFrame", function()
	for p in players.iterate do
		if not Squigglepants.inMode(SGT_RACE)
		or not (p.mo and p.mo.valid) then continue end

		p.realtime = $ - 4*TICRATE -- maybe it'll screw something up but ehhhh
        if leveltime < 4*TICRATE then
            p.pflags = $|PF_FULLSTASIS
			p.realtime = 0
        end
		
		local finished = ((p.pflags & PF_FINISHED) or p.exiting) and true or false
		if P_MobjTouchingSectorSpecial(p.mo, 4, 2)
		and not finished
		and not voteScreen.isVoting then
			P_DoPlayerFinish(p)
		elseif finished
		and voteScreen.isVoting then
			p.exiting = 0
			p.pflags = $ & ~PF_FINISHED
		end
	end
	
	if G_EnoughPlayersFinished() then
		Squigglepants.startVote()
	end
end)

Squigglepants.hud.addState({
	name = "AS-raceMain",
	---@param v videolib
	think = function(_, v)
		if leveltime < 4*TICRATE and leveltime >= TICRATE then
			local curNum = leveltime/TICRATE ---@type integer

			v.drawNum(160, 100, curNum)
			if leveltime % TICRATE == 0 then
				S_StartSound(nil, sfx_thok)
			end
		end
	end
})