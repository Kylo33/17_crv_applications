package points

import "core:slice"
import "core:testing"

@(test)
test_calculate_area :: proc(t: ^testing.T) {
	testing.expect_value(t, calculate_area([]Point{{0, 0}, {2, 2}, {3, 4}}), 5.)
}

@(test)
test_calculate_area_prefix :: proc(t: ^testing.T) {
	prefix := calculate_area_prefix([]Point{{0, 0}, {2, 2}, {3, 4}})
	defer delete(prefix)

	testing.expect(t, slice.equal(prefix, []f64{0, 2, 5}))
}

@(test)
test_normalize :: proc(t: ^testing.T) {
	point_sets := [][]Point {
		{{0, 0}, {2, 2}, {3, 4}},
		{{-3.20, 0.00}, {2.00, 3.48}, {2.65, 1.23}, {5.28, 8.62}, {7.27, 0.00}},
	}

	for points in point_sets {
		new_points := normalize(points)
		defer delete(new_points)

		testing.expect_value(t, calculate_area(new_points), 1)

		for point, i in points {
			testing.expect_value(t, new_points[i].x, point.x)
		}
	}
}

