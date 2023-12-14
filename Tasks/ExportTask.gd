extends Task

var preset_path: String
var export_path: String

func _initialize(project_path: String):
	preset_path = project_path.path_join("export_presets.cfg")

func load_presets() -> ConfigFile:
	var config_file := ConfigFile.new()
	if config_file.load(preset_path) == OK:
		return config_file
	return null

func set_export_path(path: String):
	if path.begins_with("res://"):
		export_path = path.replace("res://", Data.project_path)
	else:
		export_path = Data.project_path.path_join(path)

func _get_relevant_file_paths() -> PackedStringArray:
	var paths: PackedStringArray
	paths.append(export_path)
	paths.append(export_path.get_basename() + ".pck")
	return paths
