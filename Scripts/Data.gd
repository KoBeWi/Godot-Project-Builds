extends Node

const CONFIG_FILE = "project_builds_config.txt"
var local_config_file: String

var global_config: Dictionary
var local_config: Dictionary
var project_path: String

var tasks: Array[Dictionary]
var routines: Array[Dictionary]
var templates: Array[Dictionary]

var current_routine: Dictionary

var save_local_timer: Timer
var save_global_timer: Timer

func _init() -> void:
	for task in DirAccess.get_files_at("res://Tasks"):
		if task.get_extension() == "tscn":
			register_task("res://Tasks".path_join(task))
	
	var global_config_file := FileAccess.open("user://".path_join(CONFIG_FILE), FileAccess.READ)
	if global_config_file:
		global_config = str_to_var(global_config_file.get_as_text())
	else:
		global_config["godot_path"] = OS.get_executable_path()
	
	save_local_timer = Timer.new()
	save_local_timer.wait_time = 0.5
	save_local_timer.one_shot = true
	add_child(save_local_timer)
	
	save_global_timer = save_local_timer.duplicate()
	add_child(save_global_timer)
	
	save_local_timer.timeout.connect(save_local_config)
	save_global_timer.timeout.connect(save_global_config)

func load_project(path: String):
	project_path = path
	
	var godot := ConfigFile.new()
	godot.load(project_path.path_join("project.godot"))
	local_config_file = godot.get_value("addons", "project_builds/config_path", CONFIG_FILE)
	if local_config_file.is_absolute_path():
		local_config_file = local_config_file.trim_prefix("res://")
	
	var fa := FileAccess.open(project_path.path_join(local_config_file), FileAccess.READ)
	if fa:
		local_config = str_to_var(fa.get_as_text())

	routines = local_config["routines"]
	templates = local_config["templates"]

func register_task(scene: String):
	var data := Dictionary()
	data["scene"] = scene.get_file().get_basename()
	
	var instance: Task = load(scene).instantiate()
	data["name"] = instance._get_task_name()
	instance.free()
	
	tasks.append(data)

func create_routine() -> Dictionary:
	var routine := Dictionary()
	routine["name"] = "New Routine"
	routine["tasks"] = []
	routines.append(routine)
	return routine

func get_current_routine() -> Dictionary:
	var ret := current_routine
	current_routine = {}
	return ret

func get_template(template_name: String) -> Dictionary:
	for template in templates:
		if template["name"] == template_name:
			return template
	return {}

func get_godot_path() -> String:
	return local_config.get("godot_path", global_config["godot_path"])

func queue_save_local_config():
	save_local_timer.start()

func save_local_config():
	save_local_timer.stop()
	var fa := FileAccess.open(project_path.path_join(local_config_file), FileAccess.WRITE)
	fa.store_string(var_to_str(local_config))

func queue_save_global_config():
	save_global_timer.start()

func save_global_config():
	save_global_timer.stop()
	var fa := FileAccess.open("user://".path_join(CONFIG_FILE), FileAccess.WRITE)
	fa.store_string(var_to_str(global_config))

func _exit_tree() -> void:
	if not project_path.is_empty():
		save_local_config()
	save_global_config()
