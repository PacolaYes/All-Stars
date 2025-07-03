
-- functions related to hud
-- like getting a patch
-- pretty original stuff, i know
-- -pac

-- stores patch in table
-- other than that
-- its just cachePatch :P
local patchTable = {}
function Squigglepants.getPatch(v, name)
	if not (patchTable[name] and patchTable[name].valid) then
		patchTable[name] = v.cachePatch(name)
	end
	return patchTable[name]
end