local ReplicatedStorage = game:GetService("ReplicatedStorage")
local areProjectionsOverlapping = require(ReplicatedStorage.Modules.Utility.areProjectionsOverlapping)

return function (cf1, size1, cf2, size2)
	local axes = {
		cf1.RightVector, cf1.UpVector, cf1.LookVector,
		cf2.RightVector, cf2.UpVector, cf2.LookVector
	}

	-- Add cross-product axes (9 total)
	for i = 1, 3 do
		for j = 4, 6 do
			table.insert(axes, axes[i]:Cross(axes[j]))
		end
	end

	for _, axis in ipairs(axes) do
		if not areProjectionsOverlapping(cf1, size1, cf2, size2, axis) then
			return false -- Found a separating axis, they are NOT touching
		end
	end

	return true -- No separating axis found, they ARE touching
end