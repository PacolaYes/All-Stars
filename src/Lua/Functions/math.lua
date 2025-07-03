
-- MATH !!
-- -pac

-- make this global, because its just clamp :P
-- why make it specific to the mod variable
-- its not like clamp has different results
rawset(_G, "clamp", function(num, minimum, maximum)
	if type(num) ~= "number" then
		error("Please provide a number.", 2)
		return num
	end
	
	if minimum == nil then minimum = -1 end
	if maximum == nil then maximum = 1 end
	
	return min(max(num, minimum), maximum)
end)