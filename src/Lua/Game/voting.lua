
-- handles voting stuff
-- duh
-- returns the voting screen's HUD stuff :P

local hook = Squigglepants.Hooks
local inttime = CV_FindVar("inttime")
local roulettetime = 10 * TICRATE

---Gets a random map. Capable of blacklisting maps & gamemodes
---@param map_blacklist function?
---@param mode_blacklist function?
---@return integer, integer
function Squigglepants.getRandomMap(map_blacklist, mode_blacklist)
    local mapnum, modenum

    while modenum == nil
    or type(mode_blacklist) == "function" and mode_blacklist(modenum) do
        modenum = P_RandomRange(1, #Squigglepants.gametypes)
    end

    while mapnum == nil
    or not mapheaderinfo[mapnum]
    or not (mapheaderinfo[mapnum].typeoflevel & Squigglepants.gametypes[modenum].typeoflevel)
    or type(map_blacklist) == "function" and map_blacklist(mapnum) do
        mapnum = P_RandomRange(1, 1035)
    end

    return mapnum, modenum
end

--- ends the round :P
function Squigglepants.endRound()
    mapmusname = "KARWIN"
    S_ChangeMusic(mapmusname, true)
    Squigglepants.sync.gamestate = SST_INTERMISSION

    for mo in mobjs.iterate() do
        mo.flags = MF_NOTHINK
        mo.state = S_INVISIBLE
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype?
    local div = (gtDef and gtDef.hasIntermission) and 2 or 1

    Squigglepants.sync.inttime = inttime.value*TICRATE / div
    Squigglepants.sync.voteMaps = {}
    local foundMaps = {}
    for i = 1, 3 do
        while Squigglepants.sync.voteMaps[i] == nil
        or foundMaps[Squigglepants.sync.voteMaps[i][1]] do
            Squigglepants.sync.voteMaps[i] = {Squigglepants.getRandomMap()}
        end
        foundMaps[Squigglepants.sync.voteMaps[i][1]] = true
    end
    Squigglepants.sync.voteMaps[4] = {Squigglepants.getRandomMap()}

    if gtDef then
        gtDef:onend()
    end
end

COM_AddCommand("endround", function()
    Squigglepants.endRound()
end, COM_ADMIN)

COM_AddCommand("squiggle_setgamemode", function(_, arg)
    local gt = Squigglepants.getGametypeDef(arg)
    if not gt
    and tonumber(arg) then
        gt = Squigglepants.gametypes[tonumber(arg)]
    end

    if gt then
        G_ExitLevel()
        Squigglepants.sync.gametype = _G["SGT_"+gt.identifier:upper()]
    end
end, COM_ADMIN)

addHook("PreThinkFrame", function()
    if gametype ~= GT_SQUIGGLEPANTS
    or Squigglepants.sync.gamestate == SST_NONE then return end

    local result = hook.execHook("IntermissionThinker", nil)
    if result then return end

    Squigglepants.sync.inttime = $-1

    local selectedMaps = {}
    if Squigglepants.sync.gamestate == SST_VOTE then
        local playerList = {
            total = 0,
            selected = 0
        }
        for p in players.iterate do
            playerList.total = $+1
            if p.squigglepants.vote.selected then
                playerList.selected = $+1

                local selMap = p.squigglepants.vote.selX + 2*(p.squigglepants.vote.selY - 1)
                selectedMaps[#selectedMaps+1] = selMap
            end
        end

        if playerList.total == playerList.selected then
            Squigglepants.sync.inttime = 0
        end
    end

    if Squigglepants.sync.inttime <= 0 then
        if Squigglepants.sync.gamestate == SST_INTERMISSION then
            Squigglepants.sync.inttime = inttime.value*TICRATE / 2
            Squigglepants.sync.gamestate = SST_VOTE
        elseif Squigglepants.sync.gamestate == SST_VOTE then
            Squigglepants.sync.inttime = roulettetime
            Squigglepants.sync.gamestate = SST_ROULETTE

            local rand = #selectedMaps and selectedMaps[P_RandomRange(1, #selectedMaps)] or P_RandomRange(1, 4)
            Squigglepants.sync.selectedMap = Squigglepants.sync.voteMaps[rand]
        else
            G_SetCustomExitVars(Squigglepants.sync.selectedMap[1], 1)
            Squigglepants.sync.gametype = Squigglepants.sync.selectedMap[2]
            G_ExitLevel()
        end
    end
end)

---@param cur number
---@param minval number?
---@param maxval number?
---@return number
local function clamp(cur, minval, maxval)
    if minval == nil then
        minval = -1
    end
    if maxval == nil then
        maxval = 1
    end
    return min(max(cur, minval), maxval)
end

---@param p squigglepantsPlayer
hook.addHook("PrePlayerThink", function(p)
    if Squigglepants.sync.gamestate == SST_NONE then return end
    local vote = p.squigglepants.vote

    if Squigglepants.sync.gamestate == SST_VOTE then
        if not vote.selected then
            local oldVote = vote.selX + vote.selY
            if abs(p.cmd.forwardmove) > 15
            and abs(vote.lastcmd.forwardmove) <= 15 then
                local add = -clamp(p.cmd.forwardmove)

                vote.selY = $+add
                if vote.selY < 1 then
                    vote.selX = $-1
                elseif vote.selY > 2 then
                    vote.selX = $+1
                end
            end
            if abs(p.cmd.sidemove) > 15
            and abs(vote.lastcmd.sidemove) <= 15 then
                local add = clamp(p.cmd.sidemove)

                vote.selX = $+add
                if vote.selX < 1 then
                    vote.selY = $-1
                elseif vote.selX > 2 then
                    vote.selY = $+1
                end
            end

            if oldVote ~= vote.selX + vote.selY then
                S_StartSound(nil, sfx_menu1, p)
            end

            if vote.selX < 1 then
                vote.selX = 2
            elseif vote.selX > 2 then
                vote.selX = 1
            end
            if vote.selY < 1 then
                vote.selY = 2
            elseif vote.selY > 2 then
                vote.selY = 1
            end

            if (p.cmd.buttons & BT_JUMP)
            and not (vote.lastcmd.buttons & BT_JUMP) then
                vote.selected = true
                S_StartSound(nil, sfx_addfil, p)
            end
        elseif (p.cmd.buttons & BT_SPIN)
        and not (vote.lastcmd.buttons & BT_SPIN) then
            vote.selected = false
            S_StartSound(nil, sfx_notadd, p)
        end
    end

    vote.lastcmd.forwardmove = p.cmd.forwardmove
    vote.lastcmd.sidemove = p.cmd.sidemove
    vote.lastcmd.buttons = p.cmd.buttons
    p.cmd.forwardmove = 0
    p.cmd.sidemove = 0
    p.cmd.buttons = 0
end)

local scrollTime = 8 * TICRATE
local bgScale = FU
local mapScale = tofixed("0.9")
local mapMargin = 4 * FU

---@param v videolib
local function drawVoteBG(v)
    local patch = Squigglepants.HUD.getPatch(v, "SRB2BACK")
    local time = FixedDiv(leveltime % scrollTime, scrollTime)
    local x = ease.linear(time, -patch.width * bgScale, 0)
    local y = ease.linear(time, -patch.height * bgScale, 0)

    Squigglepants.HUD.patchFill(v, x, y, nil, nil, bgScale, patch)
end

---@param v videolib
---@param offsetX fixed_t?
---@param offsetY fixed_t?
---@param margin fixed_t?
local function drawVoteMaps(v, offsetX, offsetY, margin)
    offsetX = $ or 0
    offsetY = $ or 0
    if margin == nil then
        margin = mapMargin
    end

    local lvlWidth, lvlHeight
    for i = 1, 4 do
        local map = Squigglepants.sync.voteMaps[i]
        local lvlgfx
        local modeName
        
        if i < 4 then
            lvlgfx = Squigglepants.HUD.getPatch(v, G_BuildMapName(map[1]) + "P")
            modeName = Squigglepants.gametypes[map[2]].name
        else
            lvlgfx = Squigglepants.HUD.getPatch(v, "BLANKLVL")
            modeName = "???"
        end

        lvlWidth, lvlHeight = (lvlgfx.width * mapScale), (lvlgfx.height * mapScale)

        local xAdd = -(margin + lvlWidth)
        local yAdd = -(margin + lvlHeight)
        if (i % 2) == 0 then
            xAdd = margin
        end
        if i > 2 then
            yAdd = margin
        end

        local x, y = (160*FU + xAdd + offsetX), (100*FU + yAdd + offsetY)

        v.drawScaled(x, y, mapScale, lvlgfx, V_HUDTRANS)
        v.drawString(x + 2*FU, y + 80*FU, modeName, V_HUDTRANS, "fixed")
    end
    return lvlWidth, lvlHeight
end

---@param v videolib
local function voteHUD(v)
    local p = displayplayer ---@type squigglepantsPlayer
    local vote = p.squigglepants.vote

    drawVoteBG(v)

    local playerList = {}
    for ip in players.iterate do ---@param ip squigglepantsPlayer
        if not ip.squigglepants.vote.selected then continue end
        local ivote = ip.squigglepants.vote

        local iHover = ivote.selX + 2*(ivote.selY - 1)
        if not playerList[iHover] then
            playerList[iHover] = {ip}
        else
            table.insert(playerList[iHover], ip)
        end
    end

    local lvlWidth, lvlHeight = drawVoteMaps(v)
    local mapHovered = vote.selX + 2*(vote.selY - 1)

    local xAdd = -(mapMargin + lvlWidth)
    local yAdd = -(mapMargin + lvlHeight)
    if (mapHovered % 2) == 0 then
        xAdd = mapMargin
    end
    if mapHovered > 2 then
        yAdd = mapMargin
    end

    local x, y = (160*FU + xAdd) + 2*FU, (100*FU + yAdd) + 2*FU

    for i = 1, 4 do
        if playerList[i] then
            local margin = 2*FU
            if #playerList[i] > 6 then
                margin = -9 * (#playerList[i] - 6) * FU
            end

            for _, ip in ipairs(playerList[i]) do ---@param ip squigglepantsPlayer
                local char = v.getSprite2Patch(ip.skin, SPR2_LIFE)
                local charScale = (skins[ip.skin].flags & SF_HIRES) and skins[ip.skin].highresscale or FU

                v.drawScaled(x + char.leftoffset*charScale, y + char.topoffset*charScale, charScale, char, V_HUDTRANS, v.getColormap(ip.skin, ip.skincolor))
                x = $ + char.width*charScale + margin
            end
        end
    end

    if not vote.selected then
        local char = v.getSprite2Patch(p.skin, SPR2_LIFE)
        local charScale = (skins[p.skin].flags & SF_HIRES) and skins[p.skin].highresscale or FU

        v.drawScaled(x + char.leftoffset*charScale, y + char.topoffset*charScale, charScale, char, V_HUDTRANS, v.getColormap(TC_DEFAULT, 0, "Squigglepants_EyesOnly"))
    end
    
    v.drawString(160, 100 - 4, Squigglepants.sync.inttime/TICRATE+1, V_HUDTRANS, "center")
    v.drawString(160, 1, "please wait while the programmer takes her nap!", V_SNAPTOTOP|V_HUDTRANS|V_ALLOWLOWERCASE, "thin-center")
end

local centerTime = TICRATE - TICRATE/4
local centerWait = TICRATE / 2
local mysteryTime = 2*TICRATE + TICRATE/2
local mysteryWait = TICRATE
local waitTime = 2*TICRATE + TICRATE/2

roulettetime = centerTime + centerWait + mysteryTime + mysteryWait + waitTime
---@param v videolib
local function rouletteHUD(v)
    local p = consoleplayer ---@type squigglepantsPlayer
    local vote = p.squigglepants.vote
    local timeleft = roulettetime - Squigglepants.sync.inttime

    drawVoteBG(v)

    local blankgfx = Squigglepants.HUD.getPatch(v, "BLANKLVL") ---@type patch_t
    if timeleft < centerTime + centerWait then
        local time = min(FixedDiv(timeleft, centerTime), FU)
        for i = 1, 4 do
            local map = Squigglepants.sync.voteMaps[i]
            local lvlgfx
            local modeName
            
            if i < 4 then
                lvlgfx = Squigglepants.HUD.getPatch(v, G_BuildMapName(map[1]) + "P")
                modeName = Squigglepants.gametypes[map[2]].name
            else
                lvlgfx = blankgfx
                modeName = "???"
            end

            local lvlWidth, lvlHeight = (lvlgfx.width * mapScale), (lvlgfx.height * mapScale)

            local xAdd = -(mapMargin + lvlWidth)
            local yAdd = -(mapMargin + lvlHeight)
            if (i % 2) == 0 then
                xAdd = mapMargin
            end
            if i > 2 then
                yAdd = mapMargin
            end

            local x, y = 160*FU + ease.inquad(time, xAdd, -(mapMargin + lvlWidth/2)), 100*FU + ease.inquad(time, yAdd, -(mapMargin + lvlHeight/2))

            v.drawScaled(x, y, mapScale, lvlgfx, V_HUDTRANS)
            v.drawString(x + 2*FU, y + 80*FU, modeName, V_HUDTRANS, "fixed")
        end
    elseif timeleft < centerTime + centerWait + mysteryTime + mysteryWait then
        local time = min(FixedDiv(timeleft - (centerTime + centerWait), mysteryTime), FU)

        local xOffset, yOffset = v.RandomFixed() * v.RandomRange(-1, 1), v.RandomFixed() * v.RandomRange(-1, 1)
        xOffset, yOffset = ease.inexpo(time, $1, 8*$1), ease.inexpo(time, $2, 8*$2)

        local x, y = (160*FU - blankgfx.width*mapScale/2) + xOffset, (100*FU - blankgfx.height*mapScale/2) + yOffset
        v.drawScaled(x, y, mapScale, blankgfx, V_HUDTRANS)
        v.drawString(x + 2*FU, y + 80*FU, "???", V_HUDTRANS, "fixed")

        local trans = (v.userTransFlag() >> V_ALPHASHIFT) + FixedRound(ease.insine(time, 10*FU, 0))/FU

        if trans >= 10 then return end

        v.drawScaled(x, y, mapScale, blankgfx, trans << V_ALPHASHIFT, v.getColormap(TC_DEFAULT, SKINCOLOR_NONE, "AllWhite"))
    else
        local timeNum = timeleft - (centerTime + centerWait + mysteryTime + mysteryWait)
        local time = min(FixedDiv(timeNum, TICRATE/4), FU)

        local xOffset, yOffset = 0, 0
        
        local x, y = (160*FU - blankgfx.width*mapScale/2 + xOffset), (100*FU - blankgfx.height*mapScale/2 + yOffset)

        local map = Squigglepants.sync.selectedMap
        local lvlgfx = Squigglepants.HUD.getPatch(v, G_BuildMapName(map[1]) + "P")

        v.drawScaled(x, y, mapScale, lvlgfx, V_HUDTRANS)
        v.drawString(x + 2*FU, y + 80*FU, Squigglepants.gametypes[map[2]].name, V_HUDTRANS, "fixed")
        local trans = (v.userTransFlag() >> V_ALPHASHIFT) + FixedRound(ease.insine(time, 0, 10*FU))/FU

        if trans >= 10 then return end

        v.drawScaled(x, y, mapScale, blankgfx, trans << V_ALPHASHIFT, v.getColormap(TC_DEFAULT, SKINCOLOR_NONE, "AllWhite"))
    end
end

return voteHUD, rouletteHUD