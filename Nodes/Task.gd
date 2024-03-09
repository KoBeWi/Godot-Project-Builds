extends Control
class_name Task

var data: Dictionary

static func create_instance(scene: String) -> Task:
	return load("res://Tasks/%s.tscn" % scene).instantiate()

func _get_task_name() -> String:
	return "Empty Task"

func _get_execute_string() -> String:
	return _get_task_name()

func _initialize(project_path: String): ## TODO: po co project path
	pass

func _get_command() -> String:
	return ""

func _get_arguments() -> PackedStringArray:
	return []

func _prepare() -> void:
	pass

func _cleanup() -> void:
	pass

func _load() -> void:
	pass

func _store() -> void:
	pass

func _get_relevant_file_paths() -> PackedStringArray:
	return PackedStringArray()

func _get_task_info() -> PackedStringArray:
	return ["Task description", "Argument Name|Description"]

func get_previous_task() -> Task:
	if get_index() == 0:
		return null
	return get_parent().get_child(get_index() - 1)
