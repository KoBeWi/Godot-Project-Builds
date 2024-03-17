extends Control
class_name Task

var data: Dictionary
var has_static_configuration: bool
var error_message: String

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

func _prevalidate() -> bool:
	return true

func _validate() -> bool:
	return true

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

func _get_task_info() -> PackedStringArray:
	return [
		"Task description",
		"Argument Name|Description",
	]

static func create_instance(scene: String) -> Task:
	return load("res://Tasks/%s.tscn" % scene).instantiate()
