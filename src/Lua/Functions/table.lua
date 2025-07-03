
-- functions related to table manipulation stuff !!
-- included are:
--	Squigglepants.copy(t);
--	Squigglepants.copyTo(from, to);
-- - pac

-- simply gets a copy of a table
-- it also is recursive, meaning that
-- if the table has more tables, it'll
-- copy those seperatly too
function Squigglepants.copy(t)
	local tcopy = {}
	for key, val in pairs(t) do
		if type(val) == "table" then
			tcopy[key] = Squigglepants.copy(val)
		else
			tcopy[key] = val
		end
	end
	return tcopy
end

-- copies from the table "from" to the table "to"
-- prioritizes values from the "from" table
-- that means that "from" overwrites what both have in common.
-- calls copy (above) if a value is a table.
function Squigglepants.copyTo(from, to)
	for key, val in pairs(from) do
		if type(val) == "table" then
			if to[key] then
				to[key] = Squigglepants.copyTo(val, $)
			else
				to[key] = Squigglepants.copy(val)
			end
		else
			to[key] = val
		end
	end
	return to
end