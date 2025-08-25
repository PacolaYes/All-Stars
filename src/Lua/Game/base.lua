
-- handles the base functionality
-- maybe the name isn't that self-explanatory
-- not sure what else to call it though :P
-- -pac

Squigglepants.gametype = 1
Squigglepants.nextgametype = 1
local ogVars = Squigglepants.require("Game/voting.lua")

addHook("MapChange", function()
	---@diagnostic disable-next-line: exp-in-action, malformed-number, miss-symbol, unknown-symbol
	Squigglepants = $.copyTo(ogVars.global, $) -- reset variables that we should :D
	
	if gametype ~= GT_SQUIGGLEPANTS then
		Squigglepants.gametype = 1 -- reset it back :D
		Squigglepants.nextgametype = 1
		Squigglepants.hud.changeState("base", true)
	else
		Squigglepants.hud.changeState(
			Squigglepants.getGametypeDef(Squigglepants.nextgametype).hud,
			true
		)

		Squigglepants.gametype = Squigglepants.nextgametype
	end
	
	for p in players.iterate do
		p.squigglepants = Squigglepants.copy(ogVars.player) ---@diagnostic disable-line: inject-field
	end
end)

/*addHook("PlayerSpawn", function(p)
	p.squigglepants = Squigglepants.copy(ogVars.player)
end)*/

addHook("PlayerThink", function(p)
	if p.squigglepants == nil then
		p.squigglepants = Squigglepants.copy(ogVars.player)
	end
end)

COM_AddCommand("startvote", function()
	Squigglepants.startVote()
end, COM_ADMIN)

COM_AddCommand("setnextgametype", function(_, arg)
	if not Squigglepants.inMode() then return end

	arg = tonumber($)

	if arg == nil
	or arg < 0
	or arg > #Squigglepants.gametypes then return end

	Squigglepants.nextgametype = tonumber(arg)
	print("The next gametype will be " +Squigglepants.getGametypeDef(arg).name)
end, COM_ADMIN)