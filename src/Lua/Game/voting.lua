
-- handles voting
-- apparently it's like mk8
-- idk, i cant even play that :P
-- -pac

-- return val:
-- init values
-- for the global variable

local globalVars = {
	voteScreen = {
		isVoting = false,
		selectedMaps = {},
		tics = 0
	}
}

local playerVars = {
	votingScreen = {
		selected = 1, -- might be a bit confusing, this is which map the player has selected
		hasSelected = false, -- while this is whether the player has selected it or not
		
		-- last tic stuff
		lastsidemove = 0,
		lastbuttons = 0
	}
}

Squigglepants = $.copyTo(globalVars, $)
local voteScreen = Squigglepants.voteScreen

local function IsSpecialStage(map)
	if map == nil then map = gamemap end
	
	return (map >= sstage_start and map <= sstage_end)
	or (map >= smpstage_start and map <= smpstage_end)
end

function Squigglepants.getRandomMap(self, doMap, doGametype)
	if self == nil then self = {} end
	if doMap == nil then doMap = true end
	if doGametype == nil then doGametype = true end
	
	if doMap then
		self.map = 0
		local i = 0
		while not mapheaderinfo[self.map]
		or IsSpecialStage(self.map) do
			self.map = P_RandomRange(1, 1035)
		end
	end
	
	if doGametype then
		self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
		local i = 0
		while Squigglepants.getGametypeDef(self.gametype).exclusive do -- add map mechanism stuff l8r
			self.gametype = P_RandomRange(1, #Squigglepants.gametypes)
			
			i = $+1
			if i > 9999 then break end
		end
	end
	
	return self
end

function Squigglepants.startVote(gtBlacklist) -- blacklist only takes one argument, the gametype chosen, does not take random into account, that is always pure random
	if not Squigglepants.inMode() then return end
	
	local mapList = {}
	for i = 1, 3 do
		mapList[i] = Squigglepants.getRandomMap($)
	end
	
	if type(gtBlacklist) == "function" then -- note to self: ignore this for now
		for i = 1, 3 do
			while gtBlacklist(mapList[i].gametype) do
				mapList[i] = Squigglepants.getRandomMap($, false)
			end
		end
	end
	
	voteScreen.selectedMaps = mapList
	voteScreen.isVoting = true
	
	for mo in mobjs.iterate() do -- votes shouldn't have stuff bothering us >:(
		mo.flags = MF_NOTHINK
		mo.state = S_INVISIBLE
	end
end

-- handle player controls !
addHook("PreThinkFrame", function()
	for p in players.iterate do
		if not (p.realmo and p.realmo.valid)
		or not Squigglepants.inMode()
		or not voteScreen.isVoting then continue end
		
		local sp = p.squigglepants
		local vote = sp.votingScreen
		
		if ((p.cmd.sidemove >= 25) and not (vote.lastsidemove >= 25))
		or ((p.cmd.sidemove <= -25) and not (vote.lastsidemove <= -25))
			local add = clamp(p.cmd.sidemove)
			
			vote.selected = $+add
			if vote.selected < 1 then
				vote.selected = 4
			elseif vote.selected > 4 then
				vote.selected = 1
			end
		end
		
		if (p.cmd.buttons & BT_JUMP)
		and not (vote.lastbuttons & BT_JUMP) then
			S_StartSound(nil, 666, p) -- demon sfx :scream:
		end
		
		vote.lastbuttons = p.cmd.buttons
		vote.lastsidemove = p.cmd.sidemove
		
		p.cmd.forwardmove = 0
		p.cmd.sidemove = 0
		p.cmd.buttons = 0
	end
	
	voteScreen.tics = $+1
end)

return {
	global = globalVars,
	player = playerVars
}