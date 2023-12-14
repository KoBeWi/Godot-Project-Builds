extends SceneTree

var root_path: String

func _init() -> void:
	var args: Array[String]
	args.assign(OS.get_cmdline_user_args())
	if args.size() < 2:
		printerr("Not enough arguments. Required 2 (at least one file path + ZIP name), received %d" % args.size())
		quit(ERR_INVALID_PARAMETER)
		return
	
	var file_name: String = args.pop_back()
	if not file_name.get_extension() == "zip":
		file_name += ".zip"
	
	root_path = args[0].get_base_dir()
	if not root_path.ends_with("/"):
		root_path = root_path + "/"
	
	var zip := ZIPPacker.new()
	var zip_path := root_path.path_join(file_name)
	print("Creating ZIP file: %s" % zip_path)
	
	var error := zip.open(zip_path)
	if error != OK:
		printerr("Creating failed, error %d" % error)
		quit(error)
		return
	
	for file in args:
		pack(zip, file)
	
	zip.close()
	print("Packing finished")
	
	quit()

func pack(zip: ZIPPacker, file: String):
	var target_file := file.trim_prefix(root_path)
	
	print("Packing file: %s" % target_file)
	var data := FileAccess.get_file_as_bytes(file)
	if data.is_empty():
		var error := FileAccess.get_open_error()
		printerr("Error reading file: %d" % error)
		quit(error)
		return
	
	zip.start_file(target_file)
	zip.write_file(data)
	zip.close_file()
