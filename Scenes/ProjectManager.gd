extends Control

func _ready() -> void:
	var user_arguments := OS.get_cmdline_user_args()
	var i := user_arguments.find("--open-project")
	if i > -1:
		if user_arguments.size() < i + 2:
			push_error("No project path provided with --open-project.")
		else:
			var project_path := user_arguments[i + 1]
			if DirAccess.dir_exists_absolute(project_path):
				Data.from_plugin = true
				load_project.call_deferred(project_path)
				return
			else:
				push_error("The project provided for --open-project does not exist.")
	
	var editor_data := OS.get_user_data_dir().get_base_dir().get_base_dir()
	var project_list := ConfigFile.new()
	project_list.load(editor_data.path_join("projects.cfg"))
	
	for project in project_list.get_sections():
		var project_entry := preload("res://Nodes/ProjectEntry.tscn").instantiate()
		$VBoxContainer.add_child(project_entry)
		project_entry.set_project(project, load_project)

func load_project(project: String):
	Data.load_project(project)
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
