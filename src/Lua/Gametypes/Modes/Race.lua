
local COUNTDOWN_TIME = 4*TICRATE

Squigglepants.addGametype({
    name = "Race",
    identifier = "race",
    ---@param self SquigglepantsGametype
    ---@param p player_t
    playerThink = function(self, p)
        if leveltime <= COUNTDOWN_TIME then
            p.pflags = $1|PF_FULLSTASIS

            if leveltime % TICRATE == 0
            and leveltime > 0 then
                S_StartSound(nil, sfx_thok, p)
            end

            p.realtime = 0
            return
        end

        if not (p.pflags & PF_FINISHED)
        and not p.exiting then
            p.realtime = $ - COUNTDOWN_TIME

            if P_PlayerTouchingSectorSpecialFlag(p, SSF_EXIT) then
                P_DoPlayerFinish(p)
            end
        end
    end,
    gameHUD = function(v) ---@param v videolib
        if leveltime < COUNTDOWN_TIME then
            local timer = (COUNTDOWN_TIME / TICRATE - 1) - (leveltime / TICRATE)
            v.drawString(160, 100, timer, 0, "center")
        end
    end
})