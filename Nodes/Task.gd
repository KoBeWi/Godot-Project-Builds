extends Control
class_name Task

var data: Dictionary

func _get_task_name() -> String:
	return "Empty Task"

func _initialize(project_path: String):
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
