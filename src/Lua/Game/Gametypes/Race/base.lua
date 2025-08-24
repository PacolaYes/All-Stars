
-- who needs to play race
-- when you can play race
-- -pac

Squigglepants.addGametype({
	name = "RACE",
	identifier = "RACE",
	description = "race",
	exclusive = false,
	typeoflevel = TOL_RACE,
    hud = "AS-raceMain",
	intermission = "AS-raceIntermission"
})

local voteScreen = Squigglepants.voteScreen
local curPlacements -- is placement even the right word? -pac

addHook("MapChange", function()
	curPlacements = nil
end)

--- returns a table with the placements of each player
---@return table
local function getPlayerPlacements()
	local placements = {}
	for p in players.iterate do
		if (p.mo and p.mo.valid) then
			placements[#placements+1] = p
		end
	end

	---@param p1 player_t
	---@param p2 player_t
	table.sort(placements, function(p1, p2)
		return (p1 and p1.valid) and (p2 and p2.valid)
		and p1.realtime < p2.realtime
	end)

	return placements
end

addHook("ThinkFrame", function()
	for p in players.iterate do
		if not Squigglepants.inMode(SGT_RACE)
		or not (p.mo and p.mo.valid) then continue end
		
		local finished = ((p.pflags & PF_FINISHED) or p.exiting) and true or false
		if P_MobjTouchingSectorSpecial(p.mo, 4, 2)
		and not finished
		and voteScreen.screenState == SST_NONE then
			P_DoPlayerFinish(p)
		elseif finished
		and voteScreen.screenState != SST_NONE then
			p.exiting = 0
			p.pflags = $ & ~PF_FINISHED
		end

		if not finished then
			p.realtime = $ - 4*TICRATE -- maybe it'll screw something up but ehhhh
		end
        if leveltime < 4*TICRATE then
            p.pflags = $|PF_FULLSTASIS
			p.realtime = 0
        end
	end
	
	if G_EnoughPlayersFinished() then
		Squigglepants.startVote()
	end
end)

--- Handles the Race countdown
---@param v videolib
local function handleCountdown(v)
	if leveltime < 4*TICRATE and leveltime >= TICRATE-1 then
		local curNum = 4 - leveltime/TICRATE ---@type integer

		v.drawNum(160, 100, curNum)
		if leveltime % TICRATE == 0 then
			S_StartSound(nil, sfx_thok)
		end
	end
end

Squigglepants.hud.addState({
	name = "AS-raceMain",
	---@param v videolib
	think = function(_, v)
		handleCountdown(v)
	end
})

Squigglepants.hud.addState({
	name = "AS-raceIntermission",
	---@param v videolib
	think = function(_, v)
		if not consoleplayer then return end

		if curPlacements == nil then
			curPlacements = getPlayerPlacements()
		end

		local curY = 0
		for placement, p in ipairs(curPlacements) do ---@param p player_t
			if placement > 3 and p != consoleplayer then continue end

			if placement > 3 then
				break -- you're not going any further >:(
			else
				local charSPR, flip = v.getSprite2Patch(p.skin, SPR2_STND, false, A, 2) ---@type patch_t, boolean | integer
				flip = $ and V_FLIP or 0

				v.draw(16, charSPR.height + curY, charSPR, V_SNAPTOTOP|V_SNAPTOLEFT|flip, v.getColormap(p.skin, p.skincolor))
				curY = $ + charSPR.height / 2 + 8
			end
		end
		v.drawString(320 - 8, 200 - 16, Squigglepants.voteScreen.intermissionTics, 0, "right")
	end
})