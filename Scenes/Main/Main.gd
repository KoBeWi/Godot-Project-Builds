extends Control

signal scan_requested
signal exiting

func _ready() -> void:
	var config := ConfigFile.new()
	config.load(Data.project_path.path_join("project.godot"))
	
	%Title.text %= config.get_value("application", "config/name", "[unnamed]")
	if Data.from_plugin:
		%Back.hide()
	
	if Data.first_load:
		for task in Data.static_initialize_tasks:
			task._initialize_project()
		Data.first_load = false
		
		if Data.initial_load:
			scan_requested.emit()
			Data.initial_load = false

func go_back() -> void:
	exiting.emit()
	
	Data.save_local_config()
	Data.project_path = ""
	get_tree().change_scene_to_file("res://Scenes/ProjectManager.tscn")

func open_logs() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://BuildLogs"))
