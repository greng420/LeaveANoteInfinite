return function(cf1, size1, cf2, size2, axis)
	if axis.Magnitude < 1e-4 then return true end -- Skip zero vectors
	axis = axis.Unit

	local dist = math.abs((cf2.Position - cf1.Position):Dot(axis))

	-- Project half-sizes onto the axis
	local radius1 = (math.abs((cf1.RightVector * size1.X/2):Dot(axis)) +
		math.abs((cf1.UpVector * size1.Y/2):Dot(axis)) +
		math.abs((cf1.LookVector * size1.Z/2):Dot(axis)))

	local radius2 = (math.abs((cf2.RightVector * size2.X/2):Dot(axis)) +
		math.abs((cf2.UpVector * size2.Y/2):Dot(axis)) +
		math.abs((cf2.LookVector * size2.Z/2):Dot(axis)))

	return dist <= (radius1 + radius2)
end
