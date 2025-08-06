
-- base code for shtuff
-- like handling gamemodes!
-- for Squigglepants!
-- -pac

-- lil template for what the function can have:
-- name: self-explanatory, the gametype's name; default: "Unknown"
-- identifier: the name for the SGT_ constant; obligatory
-- description: self-explanatory, the gametype's description; default: none
-- exclusive: true or false, whether the maps has to have the gametype in its list, like normal gametypes; default: false
-- typeoflevel: TOL_ constant, which TOLs this level accepts; default: the same as the base gametype
-- hud: string, what hud does this gametype use by default? default: "base"

-- you can directly change this, go ahead!!
-- i still reccomend the function though :D
Squigglepants.gametypes = {
	tols = 0 -- TypeOfLevel that it supports
}

---@class SquiggleGametype
---@field name string The gametype's name.
---@field identifier string The identifier for the gametype.
---@field description string? The gametype's description.
---@field exclusive boolean Does this gametype only show on maps that support it?
---@field typeoflevel integer what TOL_ flags this gametype supports
---@field hud string what HUD does this gametype default to when loading a map?

function Squigglepants.addGametype(t)
	if t.identifier == nil then
		error("Please inform an identifier.")
		return
	end
	
	if t.name == nil then
		t.name = "Unknown"
	end
	
	if t.exclusive == nil then
		t.exclusive = true
	end
	if t.typeoflevel == nil then
		t.typeoflevel = TOL_COOP|TOL_SQUIGGLEPANTS
	end

	if t.hud == nil then
		t.hud = "base"
	end
	
	local curIdentifier = #Squigglepants.gametypes + 1
	t.identifier = tostring($):upper()
	rawset(_G, "SGT_"+t.identifier, curIdentifier)
	
	Squigglepants.gametypes[curIdentifier] = Squigglepants.copy(t)
	Squigglepants.gametypes.tols = $ | t.typeoflevel
end

---comment
---@param num number?
---@return SquiggleGametype
function Squigglepants.getGametypeDef(num)
	if tostring(num):lower() == "random" then
		num = P_RandomRange(1, #Squigglepants.gametypes)
	end
	num = tonumber($) or 1
	
	return Squigglepants.gametypes[num] or Squigglepants.gametypes[1]
end