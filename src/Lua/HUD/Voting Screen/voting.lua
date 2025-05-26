
-- handles the hud while you're voting
-- so the maps, bg and that kind of stuff :P
-- -pac

local voteScreen = Squigglepants.voteScreen
local HUD = Squigglepants.hud

-- imma be real, most of the time i don't know
-- the difference between padding and margin
-- including in css......
local mapMarginHoriz = 8*FU
local mapMarginTop = 8*FU
local mapScale = tofixed("0.4")

/*addHook("HUD", function(v, p)
	if gametype ~= GT_SQUIGGLEPANTS
	or not p.squigglepants
	or not Squigglepants
	or not voteScreen.isVoting then return end
	
	local vote = p.squigglepants.votingScreen
	local maps = voteScreen.selectedMaps
	
	local bg = Squigglepants.getPatch(v, "SQUIGGLEPANTS")
	local scrWidth, scrHeight = v.width(), v.height()
	v.drawStretched(
		0, 0,
		FixedDiv(scrWidth, bg.width), FixedDiv(scrHeight, bg.height),
		bg, V_NOSCALESTART|V_NOSCALEPATCH
	)
	
	local x = 160*FU - ((160 * mapScale + mapMarginHoriz)*3 + 160 * mapScale) / 2
	local y = 32*FU
	local flags = V_SNAPTOTOP
	for i = 1, 4 do
		local map = maps[i]
		local patch
		
		if map ~= nil then
			local gametype = Squigglepants.getGametypeDef(map.gametype)
			patch = Squigglepants.getPatch(v, G_BuildMapName(map.map)+"P")
			
			v.drawScaled(x, y, mapScale, patch, flags)
			v.drawString(x, y + 100*mapScale, gametype.name, flags, "small-thin-fixed")
			v.drawString(x, y + 100*mapScale + 4*FU, G_BuildMapTitle(map.map), flags, "small-thin-fixed")
		else
			patch = Squigglepants.getPatch(v, "BLANKLVL")
			v.drawScaled(x, y, mapScale, patch, flags)
		end
		
		if i == vote.selected then
			local patchName = vote.hasSelected and "SLCT2LVL" or "SLCT1LVL"
			v.drawScaled(x, y, mapScale, Squigglepants.getPatch(v, patchName), flags)
		end
		
		x = $ + patch.width * mapScale + mapMarginHoriz
	end
	--v.drawString(160*FU, 100*FU, p.squigglepants.votingScreen.selected, 0, "fixed-center")
	v.drawString(160*FU, 108*FU, "secs left: "+(10*TICRATE - voteScreen.tics)/TICRATE, 0, "fixed-center")
	
end)*/

local function thinkFunc(self, v, tics, p)
	if gametype ~= GT_SQUIGGLEPANTS
	or not p.squigglepants
	or not Squigglepants
	or not voteScreen.isVoting then return end
	
	local vote = p.squigglepants.votingScreen
	local maps = voteScreen.selectedMaps
	
	local bg = Squigglepants.getPatch(v, "SQUIGGLEPANTS")
	local scrWidth, scrHeight = v.width(), v.height()
	v.drawStretched(
		0, 0,
		FixedDiv(scrWidth, bg.width), FixedDiv(scrHeight, bg.height),
		bg, V_NOSCALESTART|V_NOSCALEPATCH
	)
	
	local x = 160*FU - ((160 * mapScale + mapMarginHoriz)*3 + 160 * mapScale) / 2
	local y = 32*FU
	local flags = V_SNAPTOTOP
	for i = 1, 4 do
		local map = maps[i]
		local patch
		
		if map ~= nil then
			local gametype = Squigglepants.getGametypeDef(map.gametype)
			patch = Squigglepants.getPatch(v, G_BuildMapName(map.map)+"P")
			
			v.drawScaled(x, y, mapScale, patch, flags)
			v.drawString(x, y + 100*mapScale, gametype.name, flags, "small-thin-fixed")
			v.drawString(x, y + 100*mapScale + 4*FU, G_BuildMapTitle(map.map), flags, "small-thin-fixed")
		else
			patch = Squigglepants.getPatch(v, "BLANKLVL")
			v.drawScaled(x, y, mapScale, patch, flags)
		end
		
		if i == vote.selected then
			local patchName = vote.hasSelected and "SLCT2LVL" or "SLCT1LVL"
			v.drawScaled(x, y, mapScale, Squigglepants.getPatch(v, patchName), flags)
		end
		
		x = $ + patch.width * mapScale + mapMarginHoriz
	end
	--v.drawString(160*FU, 100*FU, p.squigglepants.votingScreen.selected, 0, "fixed-center")
	v.drawString(160*FU, 108*FU, "secs left: "+(10*TICRATE - voteScreen.tics)/TICRATE, 0, "fixed-center")
end

HUD.addState({
	name = "votingScreen-voting",
	think = thinkFunc
})