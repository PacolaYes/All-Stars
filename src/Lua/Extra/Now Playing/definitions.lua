-- temp until .16 releases
local MUSICDEF = {
	PASWRD = {
		name = "Password Screen",
		game = "The Flintstones",
		authors = "Dean Evans",
	},
	UNUSD2 = {
		name = "Unused Song 2",
		game = "The Flintstones",
		authors = "Dean Evans",
	},
	SMGCOS = {
		name = "Cosmic Clones",
		game = "Super Mario Galaxy 2",
		authors = "Takeshi Hama, Mahito Yokota, Asuka Hayazaki",
	},
	KARWIN = {
		name = "Top Ride Results Screen",
		game = "Kirby Air Ride",
		authors = "HAL Laboratory",
	},
	M3WTIT = {
		name = "Title Screen",
		game = "Super Mario 3D World",
		authors = "Koji Kondo",
	},
	MCRBOS
		name = "The Curse",
		game = "Mamorukun's Curse!",
		authors = "Yousuke Yasui",
	},
	MCRBSA
		name = "The Curse Again"
		game = "Mamorukun's Curse!",
		authors = "Yousuke Yasui",
	},
	K64RSS
		name = "Ripple Star Select"
		game = "Kirby 64"
		authors = "Jun Ishikawa"
	}
}
/* yet to be added to the system...
Lump BFDIES
Title = Movement_Proposition
Authors = Kevin_Macleod
Soundtestpage = 1
Soundtestcond = 0
BPM = 126

Lump BFDIOV
Title = Shiny_Tech
Authors = Kevin_Macleod
Soundtestpage = 1
Soundtestcond = 0
BPM = 138

Lump BFDIHU
Title = Local_Forecast
Authors = Kevin_Macleod
Soundtestpage = 1
Soundtestcond = 0
BPM = 93
*/
local GAMEDEF = {
	["The Flintstones"] = {
		console = "SNES",
		name = "FLINT",
		img = "FRED",
	},
	["Super Mario Galaxy 2"] = {
		console = "Wii",
		name = "SMG2",
		img = "MARIO"
	},
	["Kirby Air Ride"] = {
		console = "GCN",
		name = "KAR",
		img = "KIRBY"
	},
	["Super Mario 3D World"] = {
		console = "WiiU",
		name = "3DWORLD",
		img = "MARIO"
	},
	/*["Mamorukun's Curse!"] = {
		console = "???",
		name = "CURSE",
		img = "BUNNYTHING"
	},*/
	["Kirby 64"] = {
		console = "N64",
		name = "K64",
		img = "KIRBY"
	},
}

return {MUSICDEF, GAMEDEF}