package main

import "core:flags"
import "core:fmt"
import "core:math/rand"
import "core:os"
import "points"


Cli_Args :: struct {
	data_file:   ^os.File `args:"pos=0,required"`,
	seed:        u64 `args:"pos=1,required"`,
	sample_size: int `args:"pos=2,required"`,
}

main :: proc() {
	args: Cli_Args
	flags.parse_or_exit(&args, os.args)
	defer os.close(args.data_file)

	rand.reset(args.seed)

	data_points, err := points.read_points(args.data_file)
	if err != nil {
		fmt.printfln("error: failed to read points (%v)", err)
		os.exit(1)
	}
	defer delete(data_points)

	normalized_points := points.normalize(data_points[:])
	quadratics := points.calculate_quadratics(normalized_points)

	for i := 1; i < len(data_points); i += 1 {
		a := normalized_points[i-1]
		b := normalized_points[i]
		q := quadratics[i]
		fmt.printfln("y = %vx^2 + %vx + %v \\left\\{{%v \\leq x \\leq %v \\right\\}}", q[0], q[1], q[2], a.x, b.x)
	}

	// for q in quadratics[1:] {
	// 	fmt.printfln("y = %vx^2 + %vx + %v", q[0], q[1], q[2])
	// }
}
