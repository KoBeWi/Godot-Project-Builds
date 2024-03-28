extends Task

static var is_godot_3: bool

var export_debug: bool
var override_path: bool
var preset_path: String
var export_path: String
var export_preset: String

func _init() -> void:
	has_static_configuration = true

static func _initialize_project():##TODO: aktualizować to po zmianie ścieżki
	var output: Array
	if OS.execute(Data.get_godot_path(), ["--version"], output) == OK:
		if output[0].begins_with("4"):
			is_godot_3 = false
		else:
			is_godot_3 = true

func _initialize():
	preset_path = Data.project_path.path_join("export_presets.cfg")

func _prevalidate() -> bool:
	var godot_path := Data.get_godot_path()
	if OS.execute(godot_path, ["--version"]) != OK:
		error_message = "Godot executable (%s) is not valid." % godot_path
		return false
	
	return true

func _get_command() -> String:
	return Data.get_godot_path()

func _get_arguments() -> PackedStringArray:
	var ret: PackedStringArray
	
	if is_godot_3:
		ret.append("--no-window")
	else:
		ret.append("--headless")
	
	ret.append("--path")
	ret.append(Data.project_path)
	
	if export_debug:
		ret.append("--export-debug")
	elif is_godot_3:
		ret.append("--export")
	else:
		ret.append("--export-release")
	
	ret.append(export_preset)
	
	if override_path:
		ret.append(export_path)
	
	return ret

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
		export_path = path.replace("res:/", Data.project_path)
	else:
		export_path = Data.project_path.path_join(path)
