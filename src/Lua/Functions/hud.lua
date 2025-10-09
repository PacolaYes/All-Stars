
-- hud related functions
-- hooray!!

Squigglepants.HUD = {}

local cachedPatches = {}
---cachePatch but it stores patches in a table :D
---@param v videolib
---@param name string
function Squigglepants.HUD.getPatch(v, name)
    if not (cachedPatches[name] and cachedPatches[name].valid) then
        cachedPatches[name] = v.cachePatch(name)
    end
    return cachedPatches[name]
end

---drawFill but with a patch oooooo
---@param v videolib
---@param x fixed_t?
---@param y fixed_t?
---@param width fixed_t?
---@param height fixed_t?
---@param scale fixed_t?
---@param patch patch_t
---@param flags number?
function Squigglepants.HUD.patchFill(v, x, y, width, height, scale, patch, flags)
    if x == nil
    and y == nil
    and width == nil
    and height == nil
    and flags == nil then
        flags = V_SNAPTOTOP|V_SNAPTOLEFT|V_HUDTRANS
    end
    
    x = $ or 0
    y = $ or 0
    scale = $ or FU
    flags = $ or 0
    if width == nil then
        width = 999*FU
    end
    if height == nil then
        height = 999*FU
    end

    local scrWidth, scrHeight = (v.width() / v.dupx() * FU), (v.height() / v.dupy() * FU)
    local filledWidth, filledHeight = 0, 0
    local patchWidth, patchHeight = (patch.width * scale), (patch.height * scale)
    while filledWidth < width do
        while filledHeight < height do
            v.drawScaled(
                x + filledWidth, y + filledHeight,
                scale, patch,
                flags, nil
            )

            filledHeight = $ + patchHeight
            if y + filledHeight > scrHeight then break end
        end
        filledHeight = 0
        filledWidth = $ + patchWidth

        if x + filledWidth > scrWidth then break end
    end
end

---@class custom_videolib: videolib
local custom_videolib = {
    secondplyr = false,
    videolib = nil ---@type videolib
}

---Caches a new patch using a graphic with `name` as the name. Returns nil if the graphic does not exist.
---@param name string
---@return patch_t?
function custom_videolib:cachePatch(name)
    return Squigglepants.HUD.getPatch(self.videolib, name)
end

---@param x number
---@param y number
---@param patch patch_t
---@param flags number?
---@param c colormap?
function custom_videolib:draw(x, y, patch, flags, c)
    local v = self.videolib

    flags = $ and $ & ~V_PERPLAYER or 0
    if splitscreen then
        x, y = $1*FU, $2*FU
        if self.secondplyr then
            if (flags & V_NOSCALESTART) then
                y = $ + v.height() * FU/2
            else
                y = $ + (v.height() * FU / v.dupx())/2
            end
        end

        v.drawStretched(x, y, FU, FU/2, patch, flags, c)
    else
        v.draw(x, y, patch, flags, c)
    end
end

---@param v videolib
---@return table
function custom_videolib:new(v)
    return setmetatable({videolib = v}, {
        __index = function(_, k)
            if custom_videolib[k] ~= nil then
                return custom_videolib[k]
            end
            return v[k]
        end
    })
end

---handles splitscreen, scary
---@param v videolib
---@param func function
function Squigglepants.HUD.splitscreenHandler(v, func)
    local newv = custom_videolib:new(v)

    func(newv, displayplayer, camera, newv.secondplyr)
    if splitscreen then
        newv.secondplyr = true
        func(newv, secondarydisplayplayer, camera2, newv.secondplyr)
    end
end