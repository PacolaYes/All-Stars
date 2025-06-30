
-- functions related to gamemode stuff
-- like checking if you're in a specific gamemode or not
-- -pac :P

-- checks if you're inside codename spongebob squigglepants
-- pretty self-explanatory, i think :D
-- if gametype is specified it also checks if you're
-- in that specific gametype
function Squigglepants.inMode(gt)
	return gametype == GT_SQUIGGLEPANTS
	and (gt ~= nil and Squigglepants.gametype == gt or gt == nil)
end