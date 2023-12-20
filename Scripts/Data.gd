extends Node

const CONFIG_FILE = "project_builds_config.txt"

var global_config: Dictionary
var local_config: Dictionary
var project_path: String

var tasks: Array[Dictionary]
var routines: Array[Dictionary]
var templates: Array[Dictionary]

var current_routine: Dictionary

func _init() -> void:
	for task in DirAccess.get_files_at("res://Tasks"):
		if task.get_extension() == "tscn":
			register_task("res://Tasks".path_join(task))
	
	var global_config_file := FileAccess.open("user://".path_join(CONFIG_FILE), FileAccess.READ)
	if global_config_file:
		global_config = str_to_var(global_config_file.get_as_text())
	else:
		global_config["godot_path"] = ""

func load_project(path: String):
	project_path = path
	
	local_config = load_config()
	if not local_config.is_empty():
		routines.assign(local_config["routines"])
		templates.assign(local_config["templates"])

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

func load_config() -> Dictionary:
	var fa := FileAccess.open(project_path.path_join(CONFIG_FILE), FileAccess.READ)
	if fa:
		return str_to_var(fa.get_as_text())
	return {}

func save_config(config: Dictionary):
	var fa := FileAccess.open(project_path.path_join(CONFIG_FILE), FileAccess.WRITE)
	fa.store_string(var_to_str(config))

func save_global_config():
	var fa := FileAccess.open("user://".path_join(CONFIG_FILE), FileAccess.WRITE)
	fa.store_string(var_to_str(global_config))

func save_templates():
	var config := load_config() ## TODO: zamienić na local_config
	config["templates"] = templates
	save_config(config)

func save_routines():
	var config := load_config()
	config["routines"] = routines
	save_config(config)

func get_template(template_name: String) -> Dictionary:
	for template in templates:
		if template["name"] == template_name:
			return template
	return {}

func get_godot_path() -> String:
	return local_config.get("godot_path", global_config["godot_path"])
