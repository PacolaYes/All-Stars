
local COUNTDOWN_TIME = 4*TICRATE

Squigglepants.addGametype({
    name = "Race",
    identifier = "race",
    description = "its race",
    typeoflevel = TOL_RACE,
    setup = function(self) ---@param self SquigglepantsGametype
        self.leveltime = 0
        self.winnerList = {}
    end,

    thinker = function(self) ---@param self SquigglepantsGametype
        if leveltime > COUNTDOWN_TIME then
            self.leveltime = $+1
        elseif leveltime % TICRATE == 0
        and leveltime > 0 then
            S_StartSound(nil, sfx_thok)
        end
    end,

    ---@param self SquigglepantsGametype
    ---@param p player_t
    playerThink = function(self, p)
        if leveltime <= COUNTDOWN_TIME then
            p.pflags = $1|PF_FULLSTASIS
        end

        if not (p.pflags & PF_FINISHED)
        and not p.exiting then
            p.realtime = self.leveltime

            if P_PlayerTouchingSectorSpecialFlag(p, SSF_EXIT) then
                P_DoPlayerFinish(p)

                local finishedcount, totalcount = 0, 0
                for p2 in players.iterate do
                    if not (p2.mo and p2.mo.valid) then continue end

                    if (p2.pflags & PF_FINISHED)
                    or p2.exiting then
                        finishedcount = $+1
                    end
                    totalcount = $+1
                end

                if finishedcount == totalcount then
                    Squigglepants.endRound()
                end
            end
        end
    end,

    onend = function(self) ---@param self SquigglepantsGametype
        local temp_winnerList = {}
        for p in players.iterate do
            temp_winnerList[#temp_winnerList+1] = p
        end
        table.sort(temp_winnerList, function(a, b)
            return a.realtime < b.realtime
        end)

        local trueKey = 1
        local prevPlyr
        for _, p in ipairs(temp_winnerList) do
            if not (p and p.valid) then continue end

            if (prevPlyr and prevPlyr.valid)
            and prevPlyr.realtime == p.realtime then
                table.insert(self.winnerList[trueKey-1], p)
                prevPlyr = p
                continue
            end

            self.winnerList[trueKey] = {p}
            prevPlyr = p
            trueKey = $+1
        end
    end,

    gameHUD = function(_, v) ---@param v videolib
        if leveltime < COUNTDOWN_TIME then
            local timer = (COUNTDOWN_TIME / TICRATE - 1) - (leveltime / TICRATE)
            v.drawString(160, 100, timer, 0, "center")
        end
    end,

    intermission = function(self, v) ---@param v videolib
        local yPos = 0
        local plyrPos = 1
        for key, t in ipairs(self.winnerList) do ---@param p squigglepantsPlayer
            for _, p in ipairs(t) do
                if not (p and p.valid) then continue end

                v.drawString(8, 8 + 12 * yPos, plyrPos + "- " + p.name, 0, "thin")
                yPos = $+1

                if plyrPos ~= key then
                    plyrPos = key - (#self.winnerList[key-1] - 1)
                end
            end
        end
    end
})