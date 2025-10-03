
-- hud related functions
-- hooray!!

Squigglepants.HUD = {}

---drawFill but with a patch oooooo
---@param v videolib
---@param x fixed_t?
---@param y fixed_t?
---@param width fixed_t?
---@param height fixed_t?
---@param scale fixed_t?
---@param patch patch_t
function Squigglepants.HUD.patchFill(v, x, y, width, height, scale, patch)
    x = $ or 0
    y = $ or 0
    scale = $ or FU
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
                V_SNAPTOTOP|V_SNAPTOLEFT, nil
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