extends SceneTree

var root_path: String
var include_filters: PackedStringArray
var exclude_filters: PackedStringArray

var quit_error: int

func _init() -> void:
	## TODO: make dir jak nie ma
	var args := OS.get_cmdline_user_args()
	if args.size() < 2:
		printerr("Not enough arguments. Required 2+ (source, destination, [filters]), received %d" % args.size())
		quit(ERR_INVALID_PARAMETER)
		return
	
	root_path = args[0]
	var target_path := args[1]
	
	var mode := 0
	for i in range(2, args.size()):
		var arg := args[i]
		if arg == "--include":
			mode = 1
		elif arg == "--exclude":
			mode = 2
		else:
			if mode == 1:
				include_filters.append(arg)
			elif mode == 2:
				exclude_filters.append(arg)
	
	var zip := ZIPPacker.new()
	print("Creating ZIP file: %s" % target_path)
	
	var error := zip.open(target_path)
	if error != OK:
		printerr("Creating failed, error %d" % error)
		quit(error)
		return
	
	pack_files(zip, root_path)
	
	zip.close()
	if quit_error == OK:
		print("Packing finished successfully!")
	else:
		printerr("Packing failed, check error code.")
	
	quit(quit_error)

func pack_files(zip: ZIPPacker, dir: String):
	var da := DirAccess.open(dir)
	if not da:
		printerr("Error opening directory: %s" % dir)
		quit_error = DirAccess.get_open_error()
		return
	
	da.include_hidden = true
	
	for file in da.get_files():
		var skip := not include_filters.is_empty()
		for filter in include_filters:
			if file.match(filter):
				skip = false
				break
		
		if not skip:
			for filter in exclude_filters:
				if file.match(filter):
					skip = true
					break
		
		if not skip:
			pack(zip, dir.path_join(file))
		
		if quit_error != OK:
			return
	
	for d in da.get_directories():
		pack_files(zip, dir.path_join(d))
		
		if quit_error != OK:
			return

func pack(zip: ZIPPacker, file: String):
	var target_file := file.trim_prefix(root_path + "/")
	
	print("Packing file: %s" % target_file)
	var data := FileAccess.get_file_as_bytes(file)
	if data.is_empty():
		var error := FileAccess.get_open_error()
		if error != OK:
			printerr("Error reading file: %d" % error)
			quit_error = error
			return
	
	zip.start_file(target_file)
	zip.write_file(data)
	zip.close_file()
