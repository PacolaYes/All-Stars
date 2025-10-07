
local CLONE_OFFSET = 3*TICRATE -- when the clones start showing up
local CLONES_PER_SECOND = 2 -- self-explanatory, goes up to TICRATE (35)
local CLONE_OPACITY = FU/2 -- 0 to FU, gets halved when it's not your clone

mobjinfo[freeslot("MT_SQUIGGLEPANTS_COSMICCLONE")] = {
    spawnstate = S_INVISIBLE,
    flags = MF_PAIN
}

---@class clonePos
local copyList = {
    x = 0,
    y = 0,
    z = 0,
    angle = 0,
    sprite = 0,
    sprite2 = 0,
    frame = 0
}

Squigglepants.addGametype({
    name = "Cosmic Clones",
    identifier = "cosmicclone",
    description = "galaxy D:",
    typeoflevel = TOL_RACE,
    setup = function(self) ---@param self SquigglepantsGametype
        self.clonetimer = -1

        self.cloneList = {}
    end,

    thinker = function(self) ---@param self SquigglepantsGametype
        if leveltime > CLONE_OFFSET then
            self.clonetimer = $+1
        end

        for key in ipairs(self.cloneList) do
            if not (players[key] and players[key].valid) then
                print(key)
                self.cloneList[key] = nil
                continue
            end
        end
    end,

    ---@param self SquigglepantsGametype
    ---@param p player_t
    playerThink = function(self, p)
        if not (p.mo and p.mo.valid) then return end

        if (self.clonetimer % (TICRATE / CLONES_PER_SECOND)) == 0 then
            local clonePos = self.cloneList[#p][1] ---@type clonePos
            local clone = P_SpawnMobj(clonePos.x, clonePos.y, clonePos.z, MT_SQUIGGLEPANTS_COSMICCLONE)
            clone.angle = clonePos.angle
            clone.cloneNum = #p
            clone.skin = p.mo.skin
            clone.color = SKINCOLOR_GALAXY
            clone.colorized = true
            clone.state = S_PLAY_STND
        end

        if not (p.pflags & PF_FINISHED)
        and not p.exiting then
            if P_PlayerTouchingSectorSpecialFlag(p, SSF_EXIT) then
                P_DoPlayerFinish(p)
            end

            if not self.cloneList[#p] then
                self.cloneList[#p] = {}
            end

            local cloneList_pos = #self.cloneList[#p]+1
            self.cloneList[#p][cloneList_pos] = {}
            for key in pairs(copyList) do
                self.cloneList[#p][cloneList_pos][key] = p.mo[key]
            end
            self.cloneList[#p][cloneList_pos].angle = p.drawangle
        end

        if p.playerstate ~= PST_LIVE
        or not p.mo.health then
            G_DoReborn(#p)
            p.rmomx, p.rmomy = 0, 0
            p.spectator = true
        end
    end
})

---@param mo mobj_t
addHook("MobjThinker", function(mo)
    if mo.cloneNum == nil then
        P_RemoveMobj(mo)
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype]
    if not gtDef
    or not gtDef.clonetimer
    or not gtDef.cloneList then
        P_RemoveMobj(mo)
        return
    end

    local clonePos = gtDef.cloneList[mo.cloneNum]
    if not clonePos
    or not clonePos[mo.timeAlive or 1] then
        P_RemoveMobj(mo)
        return
    end

    clonePos = clonePos[mo.timeAlive or 1]
    P_MoveOrigin(mo, clonePos.x, clonePos.y, clonePos.z)
    for key in pairs(copyList) do
        if key ~= "x"
        and key ~= "y"
        and key ~= "z" then
            mo[key] = clonePos[key]
        end
    end

    if displayplayer 
    and not splitscreen then
        if displayplayer ~= players[mo.cloneNum] then
            mo.alpha = CLONE_OPACITY/2
        else
            mo.alpha = CLONE_OPACITY
        end
    end
    mo.timeAlive = $ and $+1 or 2
end, MT_SQUIGGLEPANTS_COSMICCLONE)