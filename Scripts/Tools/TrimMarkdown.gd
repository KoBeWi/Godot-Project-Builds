extends "res://Scripts/Tools/ScriptTask.gd"

func _init() -> void:
	add_expected_argument("input", "Original markdown file to trim.")
	add_expected_argument("output", "Path to save trimmed file to.")
	add_expected_argument("header", "Header to trim file to.")

	if not fetch_arguments():
		return

	var input_path: String = arguments["input"]
	var output_path: String = arguments["output"]
	var header: String = arguments["header"]

	var error: int = OK
	error = trim_file(input_path, output_path, header)
	quit(error)

func trim_file(input_path: String, output_path: String, header: String) -> int:
	var input_file := FileAccess.open(input_path, FileAccess.READ)
	var output_file := FileAccess.open(output_path, FileAccess.WRITE)

	var writing := false
	while input_file.get_position() < input_file.get_length():
		var line = input_file.get_line()
		if not writing:
			if line.begins_with(header):
				writing = true
				output_file.store_line(line)
		else:
			var header_number = get_header_number(line)
			if header_number > 0 and header_number <= get_header_number(header):
				break
			output_file.store_line(line)

	input_file.close()
	output_file.close()

	if input_file.get_error() != OK:
		return input_file.get_error()
	return output_file.get_error()

func get_header_number(line: String) -> int:
	if line.begins_with("# "):
		return 1
	elif line.begins_with("## "):
		return 2
	elif line.begins_with("### "):
		return 3
	elif line.begins_with("#### "):
		return 4
	elif line.begins_with("##### "):
		return 5
	elif line.begins_with("###### "):
		return 6
	return 0
