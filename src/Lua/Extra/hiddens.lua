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