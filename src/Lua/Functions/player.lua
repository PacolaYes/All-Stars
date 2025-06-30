
-- functions related to player stuff
-- like get a player list or get random player
-- -pac :D

-- gets a list with all players that exist
-- blacklist should be a function
-- said function gets a player as an argument
-- returning true makes so said player is ignored
-- #playerlist = # of players that exist :P
function Squigglepants.getPlayerList(blacklist)
	local pList = {}
	for p in players.iterate do
		if type(blacklist) == "function"
		and blacklist(p) then continue end
		
		pList[#pList+1] = p
	end
	return pList
end

function Squigglepants.getRandomPlayer(blacklist)
	local rp = P_RandomRange(0, 31)
	while not (players[rp] and players[rp].valid)
	or (type(blacklist) == "function" and blacklist(players[rp])) do
		rp = P_RandomRange(0, 31)
	end
	return players[rp]
end