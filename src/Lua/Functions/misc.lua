
local storedFiles = {}

-- dofile
-- but it stores stuff
---@param file string
---@return unknown
function Squigglepants.dofile(file)
    if not storedFiles[file] then
        storedFiles[file] = dofile(file)
    end
    return storedFiles[file]
end