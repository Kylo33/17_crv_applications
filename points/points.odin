package points

import "core:math"
Point :: [2]f64

calculate_area :: proc(points: []Point) -> f64 {
	ans := 0.
	for i := 1; i < len(points); i += 1 {
		ans += pair_area(points[i - 1], points[i])
	}
	return ans
}

calculate_area_prefix :: proc(points: []Point, allocator := context.allocator) -> []f64 {
	prefix := make([dynamic]f64, allocator)
	append(&prefix, 0)

	for i := 1; i < len(points); i += 1 {
		append(&prefix, prefix[len(prefix) - 1] + pair_area(points[i - 1], points[i]))
	}

	return prefix[:]
}

pair_area :: proc(a, b: Point) -> f64 {
	triangle_height := max(a.y, b.y) - min(a.y, b.y)
	rectangle_height := min(a.y, b.y)
	width := b.x - a.x

	return triangle_height * width / 2 + rectangle_height * width
}

normalize :: proc(points: []Point, allocator := context.allocator) -> []Point {
	new_points := make([dynamic]Point)
	area := calculate_area(points)
	for point in points {
		append(&new_points, {point.x, point.y / area})
	}
	return new_points[:]
}

Quadratic :: [3]f64

calculate_quadratics :: proc(points: []Point, allocator := context.allocator) -> []Quadratic {
	quadratics := make([dynamic]Quadratic, allocator)

	// we shouldn't need this, but I want it to align indexes
	append(&quadratics, {0, 0, 0})

	for i := 1; i < len(points); i += 1 {
		a := points[i - 1]
		b := points[i]
		m := (b.y - a.y) / (b.x - a.x)

		A := m / 2
		B := a.y - m * a.x
		C := (m / 2) * a.x * a.x - a.y * a.x

		append(&quadratics, {A, B, C})
	}
	return quadratics[:]
}

inverse_cdf :: proc(u: f64, points: []Point, prefix: []f64, quadratics: []Quadratic) -> f64 {
	assert(0.0 < u && u < 1.0)

	lo := 0 // F(lo) <= u
	hi := len(prefix) - 1 // F(hi > u)
	for lo + 1 < hi {
		mid := (lo + hi) / 2
		if prefix[mid] <= u {
			lo = mid
		} else {
			hi = mid
		}
	}

	u_prime := u - prefix[lo]

	A := quadratics[hi][0]
	B := quadratics[hi][1]
	C := quadratics[hi][2] - u_prime

	x_plus := (-B + math.sqrt(B * B - 4 * A * C)) / (2 * A)
	x_minus := (-B - math.sqrt(B * B - 4 * A * C)) / (2 * A)

	if points[lo].x <= x_plus && x_plus <= points[hi].x {
		return x_plus
	}
	return x_minus
}
