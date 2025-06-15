/*
freeslots the retro
- slude
*/

local function fsCaption(sfx, caption)
	sfxinfo[freeslot("sfx_"+sfx)].caption = caption
end

freeslot(
"SPR_SRSD", 
"SPR_SRWK",
"SPR_SRJP",
"SPR_SRDD",

"MT_SO_RETRO",

"S_SR_STAND",
"S_SR_WALK",
"S_SR_DEAD",
"S_SR_JUMP"
)

fsCaption("smbdea", "Mario death")
--fsCaption("smbjum", "Mario jump")