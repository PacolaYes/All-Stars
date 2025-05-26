
local voteScreen = Squigglepants.voteScreen

addHook("HUD", function(v, p)
	if gametype ~= GT_SQUIGGLEPANTS
	or not p.squigglepants
	or not Squigglepants
	or not voteScreen.isVoting then return end
	
	local maps = voteScreen.selectedMaps
	
	local x = 0
	for i = 1, 3 do
		local map = maps[i]
		local gametype = Squigglepants.getGametypeDef(map.gametype)
		local patch = v.cachePatch(G_BuildMapName(map.map)+"P")
		
		v.drawScaled(x, 0, FU/2, patch)
		v.drawString(x, patch.height*FU/2, G_BuildMapTitle(map.map), 0, "thin-fixed")
		v.drawString(x, patch.height*FU/2 + 8*FU, gametype.name, 0, "thin-fixed")
		v.drawString(160*FU, 100*FU, p.squigglepants.votingScreen.selected, 0, "fixed-center")
		
		x = $ + patch.width*(FU/2)
	end
end)