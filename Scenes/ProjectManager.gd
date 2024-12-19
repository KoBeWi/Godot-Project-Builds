extends Control

var user_arguments := OS.get_cmdline_user_args()

func _ready() -> void:
	var i := user_arguments.find("--open-project")
	if i > -1:
		if user_arguments.size() < i + 2:
			printerr("No project path provided with --open-project.")
		else:
			var project_path := user_arguments[i + 1]
			if DirAccess.dir_exists_absolute(project_path):
				Data.from_plugin = true
				load_project.call_deferred(project_path)
				return
			else:
				printerr("The project provided for --open-project does not exist.")
	
	i = user_arguments.find("--execute-routine")
	if i > -1:
		printerr("--execute-routine was provided, but no project was opened with --open-project.")
		get_tree().quit(1)
		return
	
	i = user_arguments.find("--exit")
	if i > -1:
		printerr("--exit argument provided, but no --execute-routine. It will be ignored.")
	
	
	#region CLI --projects-file-path
	## if using different Engine Version with the ._sc_ file
	## https://docs.godotengine.org/en/4.3/tutorials/io/data_paths.html#self-contained-mode
	var editor_data : String
	i = user_arguments.find("--projects-file-path")
	if i > -1:
		if user_arguments.size() < i + 2:
			printerr("--projects-file-path -- The projects file / path is not provided")
		else:
			var project_file_path := user_arguments[i + 1]
			#region Parameter check
			#check for valid filepath
			if !project_file_path.get_file().is_empty():
				editor_data = project_file_path
			elif DirAccess.dir_exists_absolute(project_file_path): # if not a file, then check directory exists
				editor_data = project_file_path.path_join("projects.cfg")
			else:	# Fallback to default userdatadir
				editor_data = OS.get_user_data_dir().get_base_dir().get_base_dir().path_join("projects.cfg")
			#endregion
	else:
		# Fallback to default datadir
		editor_data = OS.get_user_data_dir().get_base_dir().get_base_dir().path_join("projects.cfg")
	#endregion
	
	# check if file does exists
	if !FileAccess.file_exists(editor_data):
		printerr("--projects-file-path -- File not found")
		get_tree().quit(1)
		return
		
	var project_list := ConfigFile.new()
	project_list.load(editor_data)
	
	for project in project_list.get_sections():
		var project_entry := preload("res://Nodes/ProjectEntry.tscn").instantiate()
		$VBoxContainer.add_child(project_entry)
		project_entry.set_project(project, load_project)

func load_project(project: String):
	Data.load_project(project)
	
	var i := user_arguments.find("--execute-routine")
	if i > -1:
		var j := user_arguments.find("--exit")
		if j > -1:
			Data.auto_exit = true
		
		if user_arguments.size() < i + 2:
			print("No routine name provided for --execute-routine.")
			print_routines_and_exit()
			return
		else:
			var routine_name := user_arguments[i + 1]
			for routine in Data.routines:
				if routine["name"] == routine_name:
					Data.current_routine = routine
					get_tree().change_scene_to_file("res://Scenes/Execution.tscn")
					return
			
			printerr("The routine provided for --execute-routine does not exist.")
			print_routines_and_exit()
			return
	
	i = user_arguments.find("--exit")
	if i > -1:
		printerr("--exit argument provided, but no --execute-routine. It will be ignored.")
	
	get_tree().change_scene_to_packed(Data.main)

func print_routines_and_exit():
	print("Available routines:")
	for routine in Data.routines:
		print(routine["name"])
	
	if Data.auto_exit:
		get_tree().quit(1)
