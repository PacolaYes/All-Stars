/*
freeslots the retro
- slude
*/

local function fsCaption(sfx, caption)
	sfxinfo[freeslot("sfx_"+sfx)].caption = caption
end

freeslot(
	"SPR_SRMR",

	"MT_SO_RETRO",

	"S_SR_STAND",
	"S_SR_WALK",
	"S_SR_DEAD",
	"S_SR_JUMP",
	"S_SR_SKID"
)

fsCaption("smbded", "Mario Death")
fsCaption("smbjum", "Mario Jump")
fsCaption("smbski", "Mario Skid")
