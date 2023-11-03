extends Control
class_name Task

var data: Dictionary:
	set(d):
		data = d
		_load()
	get:
		_store()
		return data

func _get_task_name() -> String:
	return "Empty Task"

func _get_command() -> String:
	return ""

func _get_arguments() -> PackedStringArray:
	return []

func _initialize(project_path: String):
	pass

func _load():
	pass

func _store():
	pass
