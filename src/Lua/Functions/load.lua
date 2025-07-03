
-- just loads stuff, yay!!!
-- -pac

dofile("Functions/file.lua")

local function load(file)
	Squigglepants.dofile("Functions/"+file)
end

load("gamemode.lua")
load("hud.lua")
load("math.lua")
load("player.lua")
load("table.lua")