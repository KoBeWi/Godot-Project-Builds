@tool
extends EditorPlugin

const CONFIG_SETTING = "addons/project_builder/config_path"

var config_path: String
var popup: PopupMenu
var cached_routine_list: PackedStringArray

func _enter_tree() -> void:
	popup = PopupMenu.new()
	popup.index_pressed.connect(on_popup_action)
	refresh_popup()
	add_tool_submenu_item("Project Builder", popup)
	
	EditorInterface.get_command_palette().add_command("Run Project Builder", "project_builder/run_project_builder", run_project_builder)
	for routine in get_routine_list():
		EditorInterface.get_command_palette().add_command("Execute: " + routine, "project_builder/" + routine, run_project_builder.bind(routine))
	
	if not ProjectSettings.has_setting(CONFIG_SETTING):
		ProjectSettings.set_setting(CONFIG_SETTING, "res://project_builds_config.txt")
	
	ProjectSettings.add_property_info({ "name": CONFIG_SETTING, "type": TYPE_STRING, "hint": PROPERTY_HINT_SAVE_FILE })
	config_path = ProjectSettings.get_setting(CONFIG_SETTING)
	ProjectSettings.settings_changed.connect(update_config_path)

func _exit_tree() -> void:
	remove_tool_menu_item("Project Builder")
	EditorInterface.get_command_palette().remove_command("project_builder/run_project_builder")
	for routine in get_routine_list():
		EditorInterface.get_command_palette().remove_command("project_builder/" + routine)

func refresh_popup():
	popup.clear()
	cached_routine_list.clear()
	
	popup.add_item("Run Project Builder")
	popup.add_item("Refresh Routine List")
	
	var routine_list := get_routine_list()
	if routine_list.is_empty():
		popup.add_separator("No Routines")
	else:
		popup.add_separator("Execute Routine")
		
		for routine in routine_list:
			popup.add_item(routine)

func update_config_path():
	var new_config_path: String = ProjectSettings.get_setting(CONFIG_SETTING)
	if new_config_path != config_path and FileAccess.file_exists(config_path):
		DirAccess.rename_absolute(config_path, new_config_path)
		config_path = new_config_path

func get_routine_list() -> PackedStringArray:
	if not cached_routine_list.is_empty():
		return cached_routine_list
	
	var routine_list: PackedStringArray
	
	var project_builds_config := FileAccess.open(ProjectSettings.get_setting(CONFIG_SETTING), FileAccess.READ)
	if project_builds_config:
		var data: Dictionary = str_to_var(project_builds_config.get_as_text())
		for routine in data["routines"]:
			routine_list.append(routine["name"])
	
	cached_routine_list = routine_list
	return routine_list

func on_popup_action(idx: int):
	match idx:
		0:
			run_project_builder()
		1:
			refresh_popup()
		_:
			run_project_builder(popup.get_item_text(idx))

func run_project_builder(routine := ""):
	var project_builds_config := FileAccess.open(EditorInterface.get_editor_paths().get_config_dir().path_join("app_userdata/Godot Project Builder/project_builds_config.txt"), FileAccess.READ)
	if not project_builds_config:
		OS.alert("Project Builder config file not found. Make sure you run Project Builder directly at least once.", "Something went wrong")
		return
	
	var data: Dictionary = str_to_var(project_builds_config.get_as_text())
	var project_path: String = data["project_builder_path"]
	
	if not DirAccess.dir_exists_absolute(project_path):
		OS.alert("Project Builder project directory found. Make sure you run Project Builder directly at least once.", "Something went very wrong")
		return
	
	var arguments: PackedStringArray
	if not project_path.is_empty():
		arguments.append_array(["--path", project_path])
	
	arguments.append_array(["--", "--open-project", ProjectSettings.globalize_path("res://").trim_suffix("/")])
	if not routine.is_empty():
		arguments.append_array(["--execute-routine", routine])
	
	var executable_path: String = data["project_builder_executable"]
	if FileAccess.file_exists(executable_path):
		OS.create_process(executable_path, arguments)
	else:
		OS.create_instance(arguments)
