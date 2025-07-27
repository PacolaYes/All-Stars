/*
freeslots the secrets
- slude

max doomednum is 65535
the doomednum is related to the object ex. lonely goombas channel was made on the 13th of the 1st month in 20*13* 
*/
freeslot(
"SPR_LLGM", 

"MT_GBAGOOMBA",

"S_GBAGOOMBA"
)

mobjinfo[MT_GBAGOOMBA] = {
	--$Title Lonely Goomba
	--$Sprite LLGMA0
	--$Category All-Stars
	--$Angled
	doomednum = 13113, -- 13/01/13
	radius = 16*FU,
	height = 48*FU,
	flags = MF_SCENERY,
	spawnstate = S_GBAGOOMBA
}

states[S_GBAGOOMBA] = {
    sprite = SPR_LLGM,
    frame = A
}
-- doesnt seem to work for some reason...