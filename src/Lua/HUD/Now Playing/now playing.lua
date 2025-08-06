
-- thing for showing the music playing thing
-- yeaghg
-- -pac

local inoutTime = TICRATE -- time it takes for the now playing thing show up and go away
local holdTime = 2*TICRATE -- time it stays on screen for

local defs = Squigglepants.dofile("HUD/Now Playing/definitions.lua")
local MUSICDEF, GAMEDEF = defs[1], defs[2]

Squigglepants.NowPlaying = {
	musicinfo = MUSICDEF,
	gameinfo = GAMEDEF
}

local ogNP = { -- np standing for now playing
	curTune = nil,
	nextTune = nil,
	time = 0,
	add = 1
}

local nowPlaying = Squigglepants.copy(ogNP)

local cachedLength = {}

local spaceLen = 8*FU
local function getLength(v, text, scale, font)
	if not v
	or text == nil
	or not scale then return end
	
	text = tostring($)
	font = $ ~= nil and tostring($):upper() or "STCFN"
	
	if not cachedLength[font] then
		cachedLength[font] = {}
	end
	
	local length = 0
	if not cachedLength[font][text] then
		for i = 1, text:len() do
			local curLetter = string.format("%03d", tostring(text:byte(i, i)))
			local patch = Squigglepants.getPatch(v, font + curLetter)
			
			if not (patch and patch.valid) then
				length = $ + spaceLen
			else
				length = $ + patch.width*FU
			end
		end
		cachedLength[font][text] = length
	end
	
	return FixedMul(cachedLength[font][text], scale)
end

local function drawText(v, x, y, scale, text, flags, align, font)
	if not v
	or x == nil
	or y == nil
	or not scale
	or text == nil then return end
	
	text = tostring($)
	flags = $ or 0
	align = $ ~= nil and tostring($):lower() or "left"
	font = $ ~= nil and tostring($):upper() or "STCFN"
	
	local startp, endp, add = 1, text:len(), 1
	if align == "right" then
		startp, endp = $2, $1
		add = -1
	elseif align == "center" then
		x = $ - getLength(v, text, scale, font) / 2
	end
	
	for i = startp, endp, add do
		local curLetter = string.format("%03d", tostring(text:byte(i, i)))
		
		if not v.patchExists(font + curLetter) then
			x = $ + FixedMul(spaceLen, scale)
			continue
		end
		
		local patch = Squigglepants.getPatch(v, font + curLetter)
		
		v.drawScaled(x, y, scale, patch, flags)
		x = $ + patch.width*scale
	end
	
	return x
end

addHook("MapChange", function()
	nowPlaying = Squigglepants.copy(ogNP)
end)

addHook("MusicChange", function(_, new)
	if gamestate ~= GS_LEVEL
	or gametype ~= GT_SQUIGGLEPANTS then return end
	
---@diagnostic disable-next-line: undefined-global, unknown-symbol
	new = $:upper()
	if not Squigglepants.NowPlaying.musicinfo[new] then return end
	
	nowPlaying.nextTune = new
	if nowPlaying.curTune then
		nowPlaying.add = -1
		nowPlaying.time = min($, inoutTime)
	end
end)

addHook("HUD", function(v, p)
	if gamestate ~= GS_LEVEL
	or gametype ~= GT_SQUIGGLEPANTS then
		return
	end
	
	if nowPlaying.curTune == nil then
		if nowPlaying.nextTune ~= nil then
			nowPlaying.curTune, nowPlaying.nextTune = $2, $1
		end
		return
	end
	
	local NowPlaying = Squigglepants.NowPlaying
	local musicInfo = NowPlaying.musicinfo[nowPlaying.curTune]
	local gameInfo = NowPlaying.gameinfo[musicInfo.game or "null"] or nil
	
	if not gameInfo then
		local nextMus = nowPlaying.nextTune
		nowPlaying = Squigglepants.copy(ogNP)
		nowPlaying.nextTune = nextMus
	end
	
---@diagnostic disable-next-line: need-check-nil, undefined-field
	local console = gameInfo.console and gameInfo.console:upper() or nil
	local part1 = Squigglepants.getPatch(v, (console and console + "CONT" or "MISSING") )
	local part2 = Squigglepants.getPatch(v, (console and console + "END" or "MISSING") )
	
	local biggestLength = max(musicInfo.name:len(), musicInfo.authors:len())
	if musicInfo.game then
		biggestLength = max($, musicInfo.game:len())
	end
	
	local contCount = biggestLength / (part1.width / 4) + 1
	
	local xAnim = 320 * FU - ease.linear(
		FixedDiv(
---@diagnostic disable-next-line: param-type-mismatch
			min(nowPlaying.time, inoutTime), inoutTime
		),
		0,
		(part1.width * contCount + part2.width) * FU
	)
	
	local flags = V_SNAPTOTOP|V_SNAPTORIGHT|V_PERPLAYER|V_HUDTRANS
	for i = 1, contCount do
		v.draw(
			FixedRound(xAnim)/FU + (part1.width * i),
			0,
			part1,
			flags
		)
	end
	v.draw(
		FixedRound(xAnim)/FU,
		0,
		part2,
		flags
	)
	
	local textX = xAnim + part2.width * (FU/2)
	drawText(v, textX, 6*FU, FU/2, musicInfo.name, flags)
	drawText(v, textX, 12*FU, FU/2, musicInfo.authors, flags)
	if musicInfo.game then
		drawText(v, textX, 18*FU, FU/2, musicInfo.game, flags)
	end
	
---@diagnostic disable-next-line: need-check-nil, undefined-field
	local iconName = (musicInfo.img or gameInfo.img or gameInfo.name or "TEST") + "_" + (gameInfo.name or "TEST")
	
	if not v.patchExists(iconName) then
		iconName = "TEST_TEST"
	end
	
	local iconThingie = Squigglepants.getPatch(v, iconName)
	local iconScale = FU/2
	local iconX = textX - part2.width * (FU/2) - iconThingie.width * (iconScale - iconScale / 4)
	v.drawCropped(
		iconX, 0,
		iconScale, iconScale,
		iconThingie, flags,
		nil, 0, 0,
		iconThingie.width * FU, (iconThingie.height - 9) * FU
	)
	for i = (iconThingie.height - 9), iconThingie.height do
		local hudtrans = v.localTransFlag()
		local trans = (hudtrans >> FF_TRANSSHIFT) + (9 - (iconThingie.height - i))
		
		if trans > 9 then break end -- higher than 9 means that the rest wouldn't draw anyways :P
		
		v.drawCropped(
			iconX, i * iconScale,
			iconScale, iconScale,
			iconThingie, (flags & ~V_HUDTRANS)|(trans << FF_TRANSSHIFT),
			nil, 0, i * FU,
			iconThingie.width * FU, FU
		)
	end
	
	-- thinker stuff below
	
	nowPlaying.time = $ + nowPlaying.add
	
	if nowPlaying.time > inoutTime+holdTime and nowPlaying.add == 1
	or nowPlaying.time < 0 and nowPlaying.add == -1 then
		if nowPlaying.add == 1 then
			nowPlaying.add = -1
			nowPlaying.time = inoutTime
		else
			local nextMus = nowPlaying.nextTune
			nowPlaying = Squigglepants.copy(ogNP)
			nowPlaying.nextTune = nextMus
		end
	end
end)
