package points

import "core:os"
import "core:strconv"
import "core:strings"
Read_Points_Error :: union {
	os.Error,
	Read_Points_Parse_Error,
}

Read_Points_Parse_Error :: enum {
	Too_Few_Fields,
	Too_Many_Fields,
	Bad_Parse,
}

read_points :: proc(
	f: ^os.File,
	allocator := context.allocator,
) -> (
	points: [dynamic]Point,
	err: Read_Points_Error,
) {
	data := os.read_entire_file(f, context.allocator) or_return
	defer delete(data)

	data_str := string(data)
	for line in strings.split_lines_iterator(&data_str) {
		fields := strings.fields(line)
		defer delete(fields)

		if len(fields) < 2 {
			err = .Too_Few_Fields
			return
		}
		if len(fields) > 2 {
			err = .Too_Many_Fields
			return
		}

		x, x_ok := strconv.parse_f64(fields[0])
		if !x_ok {
			err = .Bad_Parse
			return
		}

		y, y_ok := strconv.parse_f64(fields[1])
		if !y_ok {
			err = .Bad_Parse
			return
		}

		append(&points, {x, y})
	}

	return
}
