
-- functions to be used on more of a 
-- global level, stuff like:
-- 	- getting a table copy
--	- copying from one table to another
-- 	- insert more as we do more
-- -pac :D

-- simply gets a copy of a table
function Squigglepants.copy(t)
	local tcopy = {}
	for key, val in pairs(t) do
		tcopy[key] = val
	end
	return tcopy
end

-- copies from the table "from" to the table "to"
-- prioritizes values from the "from" table
-- that means that "from" overwrites what both have in common.
function Squigglepants.copyTo(from, to)
	for key, val in pairs(from) do
		to[key] = val
	end
	return to
end

-- pretty much require, i think?
-- i don't know, would require be closer to dofile or loadfile?
local loadedFiles = {}
function Squigglepants.dofile(file)
	if not loadedFiles[file] then
		loadedFiles[file] = dofile(file)
	end
	return loadedFiles[file]
end

Squigglepants.require = Squigglepants.dofile -- i think this makes it an alias

-- checks if you're inside codename spongebob squigglepants
-- pretty self-explanatory, i think :D
function Squigglepants.inMode()
	return gametype == GT_SQUIGGLEPANTS
end

-- gets how many players exist
-- blacklist should be a function
-- said function gets a player as an argument
-- returning true makes so said player is ignored
function Squigglepants.getPlayerCount(blacklist)
	local numPlyr = 0
	for p in players.iterate do
		if type(blacklist) == "function"
		and blacklist(p) then continue end
		
		numPlyr = $+1
	end
	return numPlyr
end

-- below ill only do MATH related stuff
-- i know, its pretty scary

-- make this global, because its just clamp :P
-- why make it specific to the mod variable
-- its not like clamp has different results
rawset(_G, "clamp", function(num, minimum, maximum)
	if type(num) ~= "number" then
		error("Please provide a number.", 2)
		return num
	end
	
	if minimum == nil then minimum = -1 end
	if maximum == nil then maximum = 1 end
	
	return min(max(num, minimum), maximum)
end)