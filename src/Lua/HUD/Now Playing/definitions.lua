local MUSICDEF = {
	MK8LVL = {
		name = "Online Menu",
		game = "Mario Kart 8",
		authors = "Ryo Magamatsu, Atsuko Asahi, Shiho Fuji, Yasuaki Iwata",
	},
	MKWLVL = {
		name = "Wi-Fi Menu",
		game = "Mario Kart Wii",
		authors = "Asuka Ohta, Ryo Nagamatsu",
	},
	POKRAT = {
		name = "Race Against Time!",
		game = "Plok",
		authors = "Tim Follin, Geoff Follin",
	},
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
	KSSHLE = {
		name = "Escape the Halberd",
		game = "Kirby Super Star",
		authors = "Jun Ishikawa",
	},
	RPGSAD = {
		name = "Sad Song",
		game = "Super Mario RPG",
		authors = "Yoko Shimomura",
	},
	SMGCOS = {
		name = "Cosmic Clones",
		game = "Super Mario Galaxy 2",
		authors = "Takeshi Hama, Mahito Yokota, Asuka Hayazaki",
	},
}

local GAMEDEF = {
	["The Flintstones"] = {
		console = "SNES",
		name = "FLINT",
		img = "FRED",
	},
	["Mario Kart Wii"] = {
		console = "Wii",
		name = "MKWII",
		img = "MNL",
	},
	["Mario Kart 8"] = {
		console = "WiiU",
		name = "MK8",
		img = "MARIO",
	},
	["Plok"] = {
		console = "SNES",
		name = "PLOK",
		img = "PLOK",
	},
	["Kirby Super Star"] = {
		console = "SNES",
		name = "KSS",
		img = "KIRBY",
	},
	["Super Mario RPG"] = {
		console = "SNES",
		name = "MARIORPG",
		img = "MARIO"
	},
	["Super Mario Galaxy 2"] = {
		console = "Wii",
		name = "SMG2",
		img = "MARIO"
	},
}

return {MUSICDEF, GAMEDEF}