extends Node

const TEMPLATES_FILE = "user://templates.txt"
const ROUTINES_FILE = "user://routines.txt"

var project_path: String = "X:/Godot/Projects/ProjectBuilds/Testing/TestProject"

var tasks: Array[Dictionary]
var routines: Array[Dictionary]
var templates: Array[Dictionary]

var current_routine: Dictionary

func _init() -> void:
	for task in DirAccess.get_files_at("res://Tasks"):
		register_task("res://Tasks".path_join(task))
	
	var fa := FileAccess.open(TEMPLATES_FILE, FileAccess.READ)
	if fa:
		templates.assign(str_to_var(fa.get_as_text()))
	
	fa = FileAccess.open(ROUTINES_FILE, FileAccess.READ)
	if fa:
		routines.assign(str_to_var(fa.get_as_text()))

func register_task(scene: String):
	var data := Dictionary()
	data["scene"] = scene
	
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

func save_templates():
	var fa := FileAccess.open(TEMPLATES_FILE, FileAccess.WRITE)
	fa.store_string(var_to_str(templates))

func save_routines():
	var fa := FileAccess.open(ROUTINES_FILE, FileAccess.WRITE)
	fa.store_string(var_to_str(routines))

func get_template(template_name: String) -> Dictionary:
	for template in templates:
		if template["name"] == template_name:
			return template
	return {}
