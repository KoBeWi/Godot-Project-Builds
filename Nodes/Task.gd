extends Control
class_name Task

var data: Dictionary
var has_static_configuration: bool

func _get_task_name() -> String:
	return "Empty Task"

func _get_execute_string() -> String:
	return _get_task_name()

static func _initialize_project():
	pass

static func _process_file(path: String):
	pass

func _initialize():
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
	return [
		"Task description",
		"Argument Name|Description",
	]

static func create_instance(scene: String) -> Task:
	return load("res://Tasks/%s.tscn" % scene).instantiate()

func get_previous_task() -> Task:
	if get_index() == 0:
		return null
	return get_parent().get_child(get_index() - 1)
