extends Task

static var is_godot_3: Variant

var export_debug: bool
var override_path: bool
var preset_path: String
var export_path: String

func _initialize(project_path: String):
	preset_path = project_path.path_join("export_presets.cfg")
	
	if is_godot_3 == null:
		var output: Array
		if OS.execute(Data.get_godot_path(), ["--version"], output) == OK:
			if output[0].begins_with("4"):
				is_godot_3 = false
			else:
				is_godot_3 = true

func _prepare():
	var base_dir := export_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(base_dir)

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

func _get_arguments() -> PackedStringArray:
	var ret: PackedStringArray
	
	if is_godot_3:
		ret.append("--no-window")
	else:
		ret.append("--headless")
	
	if export_debug:
		ret.append("--export-debug")
	elif is_godot_3:
		ret.append("--export")
	else:
		ret.append("--export-release")
	
	if override_path:
		ret.append(export_path)
	
	return ret
