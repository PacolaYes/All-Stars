
---@class SquigglepantsGametype: table
local gametypeDefault = {
    name = "UNDEFINED", ---@type string The gametype's name, shows up on the Player List & Voting Screen.
    identifier = "UNDEFINED", ---@type string The gametype's identifier, "spongebob" would make it so the gametype is identified as SGT_SPONGEBOB code-wise.
    thinker = nil, ---@type function? ThinkFrame, but only when the gametype is active.<br>- Function has a self argument, representing the gametype's definition.
    playerThink = nil, ---@type function? PlayerThink, but only when the gametype is active.<br>- Function has a self argument, representing the gametype's definition.
    gameHUD = nil, ---@type function? A normal "game" type HUD hook, but only when the gametype is active.<br><br>Check the [wiki's page](https://wiki.srb2.org/wiki/Lua/Functions#HUD_hooks) for more information.
    intermission = nil --- @type function? This mode's intermission HUD function, skips directly to vote if none is given.
}

-- not recommended to directly modify this, but do whatever u want
Squigglepants.gametypes = {} ---@type table<SquigglepantsGametype>

--- adds a gametype
---@param definition SquigglepantsGametype
function Squigglepants.addGametype(definition)
    if type(definition) ~= "table" then
        error("wheres the definition", 2)
        return
    end

    if type(definition.name) ~= "string"
    or type(definition.identifier) ~= "string" then
        error("Oops! It seems you've forgotten to specify some of the arguments!", 2)
        return
    end

    local idName = "SGT_" + definition.identifier:upper()
    local idNum = #Squigglepants.gametypes + 1
    if _G[idName] ~= nil then
        idNum = _G[idName]
    else
        rawset(_G, idName, idNum)
    end

    Squigglepants.gametypes[idNum] = definition
end

--- gets a gametype's identifier by gametype name; name is case-sensitive.
---@param name string
---@return SquigglepantsGametype?
function Squigglepants.getGametypeDef(name)
    if type(name) != "string" then
        error("Oops! It seems you've forgotten to specify a name!", 2)
        return
    end

    for _, value in ipairs(Squigglepants.gametypes) do
        if type(value) == "table"
        and value.name == name then
            return value
        end
    end
end

addHook("ThinkFrame", function()
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype]
    if not gtDef then
        return
    end

    if type(gtDef.thinker) == "function" then
        gtDef:thinker()
    end
end)

---@param p player_t
addHook("PlayerThink", function(p)
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype]
    if not gtDef then
        return
    end

    if type(gtDef.playerThink) == "function" then
        gtDef:playerThink(p)
    end
end)

-- handle gametype HUD stuff
customhud.SetupItem("Squigglepants_Main", "Squigglepants", function(v)
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype?
    if not gtDef then
        return
    end

    if type(gtDef.gameHUD) == "function" then
        gtDef.gameHUD(v)
    end
end, "gameandscores")