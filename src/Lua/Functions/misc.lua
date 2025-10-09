
local storedFiles = {}

-- dofile
-- but it stores stuff
---@param file string
---@return ...any
function Squigglepants.dofile(file)
    if not storedFiles[file] then
        storedFiles[file] = {dofile(file)}
    end

    if type(storedFiles[file]) == "table" then
        return unpack(storedFiles[file])
    end
    return(storedFiles[file])
end

---returns a copy of table `t`
---@param t table
---@return table
function Squigglepants.copy(t)
    local copy = {}
    for key, val in pairs(t) do
        if type(val) == "table" then
            copy[key] = Squigglepants.copy(val)
        else
            copy[key] = val
        end
    end
    return copy
end

---returns if value `val` is in table `t`
---@param t table
---@param val any
---@return boolean
function Squigglepants.find(t, val)
    for _, tval in pairs(t) do
        if tval == val then
            return true
        end
    end
    return false
end