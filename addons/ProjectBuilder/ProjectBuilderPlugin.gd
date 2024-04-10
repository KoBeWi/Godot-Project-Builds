@tool
extends EditorPlugin

const CONFIG_SETTING = "addons/project_builder/config_path"

var config_path: String

func _enter_tree() -> void:
	add_tool_menu_item("Run Project Builder", run_pb)
	EditorInterface.get_command_palette().add_command("Run Project Builder", "run_project_builds", run_pb)
	
	if not ProjectSettings.has_setting(CONFIG_SETTING):
		ProjectSettings.set_setting(CONFIG_SETTING, "res://project_builds_config.txt")
	
	ProjectSettings.add_property_info({ "name": CONFIG_SETTING, "type": TYPE_STRING, "hint": PROPERTY_HINT_SAVE_FILE })
	config_path = ProjectSettings.get_setting(CONFIG_SETTING)
	ProjectSettings.settings_changed.connect(update_config_path)

func _exit_tree() -> void:
	remove_tool_menu_item("Run Project Builder")
	EditorInterface.get_command_palette().remove_command("run_project_builds")

func update_config_path():
	var new_config_path: String = ProjectSettings.get_setting(CONFIG_SETTING)
	if new_config_path != config_path and FileAccess.file_exists(config_path):
		DirAccess.rename_absolute(config_path, new_config_path)
		config_path = new_config_path

func run_pb():
	var project_builds_config := FileAccess.open(EditorInterface.get_editor_paths().get_config_dir().path_join("app_userdata/Godot Project Builder/project_builds_config.txt"), FileAccess.READ)
	if not project_builds_config:
		OS.alert("Project Builder config file not found. Make sure you run Project Builder directly at least once.", "Something went wrong")
		return
	
	var data: Dictionary = str_to_var(project_builds_config.get_as_text())
	var project_path: String = data["project_builder_path"]
	
	if not DirAccess.dir_exists_absolute(project_path):
		OS.alert("Project Builder project directory found. Make sure you run Project Builder directly at least once.", "Something went very wrong")
		return
	
	var executable_path: String = data["project_builder_executable"]
	var arguments: PackedStringArray = ["--", "--open-project", ProjectSettings.globalize_path("res://").trim_suffix("/")]
	if not project_path.is_empty():
		arguments = PackedStringArray(["--path", project_path]) + arguments
	
	if FileAccess.file_exists(executable_path):
		OS.create_process(executable_path, arguments)
	else:
		OS.create_instance(arguments)
