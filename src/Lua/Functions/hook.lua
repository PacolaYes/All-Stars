
-- handles squigglepants' specific hook stuff
-- if u for some reason wanna mod it

Squigglepants.Hooks = {}

local hookList = {
    ["IntermissionThinker"] = true,
    ["PrePlayerThink"] = true
}
local hooks = {}

---adds a squigglepants hook
---@param type any
---@param func function
---@param extra string | integer?
---@return boolean
function Squigglepants.Hooks.addHook(type, func, extra)
    if hookList[type] then
        if not hooks[type] then
            hooks[type] = {}
        end

        table.insert(hooks[type], {func, extra})
        return true
    end
    return false
end

---executes a squigglepants hook
---@param type any
---@param extraFunc function?
---@return unknown
function Squigglepants.Hooks.execHook(type, extraFunc, ...)
    local result
    if hookList[type]
    and hooks[type] then
        for _, val in ipairs(hooks[type]) do
            if extraFunc and extraFunc(val[2])
            or not extraFunc then
                result = val[1](...)
            end
        end
    end
    return result
end

addHook("PreThinkFrame", function()
    if gametype ~= GT_SQUIGGLEPANTS then return end

    for p in players.iterate do
        if p.squigglepants then
            p.squigglepants.cmd.forwardmove = p.cmd.forwardmove
            p.squigglepants.cmd.sidemove = p.cmd.sidemove
            p.squigglepants.cmd.buttons = p.cmd.buttons
        end
        
        Squigglepants.Hooks.execHook("PrePlayerThink", nil, p)
    end
end)