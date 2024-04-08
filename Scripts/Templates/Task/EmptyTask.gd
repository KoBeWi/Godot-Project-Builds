extends Task

func _get_task_name() -> String:
	return "Empty Task"

func _get_execute_string() -> String:
	return _get_task_name()

static func _initialize_project() -> void:
	pass

static func _process_file(path: String) -> void:
	pass

func _initialize() -> void:
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
