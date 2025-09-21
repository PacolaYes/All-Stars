
-- handles voting stuff
-- duh
-- returns the voting screen's HUD stuff :P

--- ends the round :P
function Squigglepants.endRound()
    Squigglepants.sync.gamestate = SST_INTERMISSION

    for mo in mobjs.iterate() do
        mo.flags = MF_NOTHINK
        mo.state = S_INVISIBLE
    end

end

COM_AddCommand("endround", function()
    Squigglepants.endRound()
end, COM_ADMIN)


---@param v videolib
return function(v)
    v.drawString(160, 200 - 8, "im voting", 0, "center")
end