extends Control

func _ready() -> void:
	var user_arguments := OS.get_cmdline_user_args()
	var editor_data := OS.get_user_data_dir().get_base_dir().get_base_dir()
	var project_list := ConfigFile.new()
	project_list.load(editor_data.path_join("projects.cfg"))
	
	for project in project_list.get_sections():
		if project in user_arguments:
			load_project(project)
			return
		
		var project_entry := preload("res://Nodes/ProjectEntry.tscn").instantiate()
		$VBoxContainer.add_child(project_entry)
		project_entry.set_project(project, load_project)

func load_project(project: String):
	Data.load_project(project)
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
