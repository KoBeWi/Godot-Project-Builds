extends "BaseScriptTask.gd"

func _init() -> void:
	add_expected_argument("source", "Directory to clear.")
	
	if not fetch_arguments():
		return
	
	var directory_path: String = arguments["source"]
	
	DirAccess.make_dir_recursive_absolute("user://Trash")
	
	var counter: int
	var fail_counter: int
	for file in DirAccess.get_files_at(directory_path):
		print("Removing file: %s" % file)
		var error := DirAccess.rename_absolute(directory_path.path_join(file), "user://Trash".path_join(file))
		if error == OK:
			counter += 1
		else:
			fail_counter += 1
			printerr("Failed! Error: %d" % error)
	
	if fail_counter > 0:
		print("Cleanup finished. Cleared %d files, %d files failed." % [counter, fail_counter])
	elif counter > 0:
		print("Cleanup finished successfully. Cleared %d files." % counter)
	else:
		print("No files to cleanup.")
	
	quit(OK)
