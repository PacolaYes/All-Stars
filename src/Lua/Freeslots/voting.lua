
-- freeslots the voting
-- -pac

local function fsCaption(sfx, caption)
	sfxinfo[freeslot("sfx_"+sfx)].caption = caption
end

fsCaption("spvsel", "Selection")