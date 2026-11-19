package main

import "core:flags"
import "core:fmt"
import "core:os"
import "points"


Cli_Args :: struct {
	data_file: ^os.File `args:"name=i,required"`,
}

main :: proc() {
	args: Cli_Args
	flags.parse_or_exit(&args, os.args)
	defer os.close(args.data_file)

	points, err := points.read_points(args.data_file)
	if err != nil {
		fmt.printfln("error: failed to read points (%v)", err)
		os.exit(1)
	}
	defer delete(points)

	for point in points {
		fmt.println(point)
	}
}
