extends Node

var project_path: String = "X:/Godot/Projects/ProjectBuilds/Testing/TestProject"

var tasks: Array[Dictionary]
var routines: Array[Dictionary]

var current_routine: Dictionary

func _init() -> void:
	for task in DirAccess.get_files_at("res://Tasks"):
		register_task("res://Tasks".path_join(task))

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
