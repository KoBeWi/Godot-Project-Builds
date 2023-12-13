extends Task

var preset_path: String

func _initialize(project_path: String):
	preset_path = project_path.path_join("export_presets.cfg")

func load_presets() -> ConfigFile:
	var config_file := ConfigFile.new()
	if config_file.load(preset_path) == OK:
		return config_file
	return null
