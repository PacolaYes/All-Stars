
-- only really the require-like (i think?)
-- function that's mapped as Squigglepants.dofile
-- and also Squigglepants.require
-- -pac

-- pretty much require, i think?
-- i don't know, would require be closer to dofile or loadfile?
local loadedFiles = {}
---Does the same as dofile, except it caches the result
---@param file string
---@return any
function Squigglepants.dofile(file)
	if not loadedFiles[file] then
		loadedFiles[file] = dofile(file)
	end
	return loadedFiles[file]
end

Squigglepants.require = Squigglepants.dofile -- i think this makes it an alias