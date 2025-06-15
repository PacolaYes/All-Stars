
-- thing for showing the music playing thing
-- yeaghg
-- -pac

local inoutTime = TICRATE -- time it takes for the now playing thing show up and go away
local holdTime = 2*TICRATE -- time it stays on screen for

local MUSICDEF = { -- i lov auto generation :D
	MK8LVL = {
		name = "Online Menu",
		game = "Mario Kart 8",
		authors = "Ryo Magamatsu, Atsuko Asahi, Shiho Fuji, Yasuaki Iwata"
	},
	MKWLVL = {
		name = "Wi-Fi Menu",
		game = "Mario Kart Wii",
		authors = "Asuka Ohta, Ryo Nagamatsu"
	},
	RACTIM = {
		name = "Race Against Time!",
		game = "Plok",
		authors = "Tim Follin, Geoff Follin"
	},
	MUSBOX = {
		name = "Music Box",
		game = "Super Mario All-Stars",
		authors = "Koji Kondo"
	},
	PASWRD = {
		name = "Password Screen",
		game = "The Flintstones",
		authors = "Dean Evans"
	},
	UNUSD2 = {
		name = "Unused Song 2",
		game = "The Flintstones",
		authors = "Dean Evans"
	}
}

local GAMEDEF = {
	["Plok"] = {
		console = "SNES",
		name = "PLOK"
	},
	["Super Mario All-Stars"] = {
		console = "SNES",
		name = "SMAS"
	},
	["Super Mario RPG"] = {
		console = "SNES",
		name = "SMRPG"
	},
	["Mario Kart Wii"] = {
		console = "Wii",
		name = "MKWII"
	},
	["Mario Kart 8"] = {
		console = "WiiU",
		name = "MK8"
	}
}

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
		cachedLenght[font] = {}
	end
	
	local textLength = text:len()
	local length = 0
	if not cachedLength[font][text] then
		for i = 1, textLength do
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
		x = $ - getLength(v, text, scale, font, maxX) / 2
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
	local gameInfo = NowPlaying.gameinfo[musicInfo.game or "null"] or {}
	
	local patchName = gameInfo.console and gameInfo.console:upper() + "BG" or "MISSING"
	local patch = Squigglepants.getPatch(v, patchName)
	
	local xAnim = 320 * FU + ease.linear(
		FixedDiv(
			min(nowPlaying.time, inoutTime), inoutTime
		),
		0,
		-patch.width * FU
	)
	
	local flags = V_SNAPTOTOP|V_SNAPTORIGHT|V_PERPLAYER|V_HUDTRANS
	v.draw(
		FixedRound(xAnim)/FU,
		0,
		patch,
		flags
	)
	
	local gameName = musicInfo.game
	drawText(v, xAnim + 40*FU, 6*FU, FU/2, gameName, flags)
	
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