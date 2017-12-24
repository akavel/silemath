-- Operations on 2D geometric transformation matrices,
-- just enough to support silemath for svgmath output.
-- Based on
-- https://www.w3.org/TR/SVG/coords.html#EstablishingANewUserSpace
-- and further subchapters.
local matrix = {}

-- table {s1, k1, k2, s2, t1, t2} represents a matrix:
--   _        _
--  | s1 k2 t1 |
--  | k1 s2 t2 |
--  |_ 0  0  1_|
--
-- where 't' is for 'translate', 's' for 'scale', 'k' for 'skew'

-- mul returns a new table, representing multiplication of
-- matrices A*B
function matrix.mul(A, B)
	return {
		A[1]*B[1] + A[3]*B[2],
		A[2]*B[1] + A[4]*B[2],
		A[1]*B[3] + A[3]*B[4],
		A[2]*B[3] + A[4]*B[4],
		A[1]*B[5] + A[3]*B[6] + A[5],
		A[2]*B[5] + A[4]*B[6] + A[6],
	}
end
-- apply transformation matrix to 2D point coordinates
-- (multiply matrix and vector A*v)
function matrix.apply(A, vx, vy)
	return A[1]*vx + A[3]*vy + A[5],
		A[2]*vx + A[4]*vy + A[6]
end

function matrix.identity()
	return {1, 0, 0, 1, 0, 0}
end
function matrix.translate(tx, ty)
	return {1, 0, 0, 1, tx, ty}
end
function matrix.scale(sx, sy)
	return {sx, 0, 0, sy, 0, 0}
end

return matrix

