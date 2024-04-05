extends Control
class_name Task

## If [code]true[/code], the script will receive [method _initialize_project] and [method _process_file] calls when a project is opened.
@export var has_static_configuration: bool

## Default values for data properties. Set them inside [method _initialize].
var defaults: Dictionary#[String, Variant]
## The actual data values. Use [method _load] and [method _store] for serializing it.
var data: Dictionary#[String, Variant]

## Set this for displaying error message in [method _prevalidate] and [method _validate].
var error_message: String

## The name that displays on the list of tasks. It should be a constant string.
func _get_task_name() -> String:
	return "Empty Task"

## The name that displays when the task is being executed. You can provide extra details about the configuration from [member data].
func _get_execute_string() -> String:
	return _get_task_name()

## Called when a project is loaded if [member has_static_configuration] is [code]true[/code]. You can use it to initialize static data specific to a project, which should be global to each instance of this task.
static func _initialize_project() -> void:
	pass

## Called when a project is loaded if [member has_static_configuration] is [code]true[/code]. This method will be invoked for every file in the project. You can use it to collect configuration files specific for this task.
static func _process_file(path: String) -> void:
	pass

## Called when the task is being initialized. Use it to fill [member defaults] and initialize child [Control] node values.
func _initialize() -> void:
	pass

## Called at the beginning of a routine to check for obvious mistakes and missing information. Return [code]false[/code] if the task can't run and fill [member error_message].
func _prevalidate() -> bool:
	return true

## Called just before task is executed to check for invalid configuration, especially when it depends on previous tasks. Return [code]false[/code] if the task can't run and fill [member error_message].
func _validate() -> bool:
	return true

## Return the executable name that will run this task.
func _get_command() -> String:
	return ""

## Return the arguments provided for launching the executable.
func _get_arguments() -> PackedStringArray:
	return []

## Called before running the task. Use it to setup necessary configuration for running the task, especially temporary one.
func _prepare() -> void:
	pass

## Called after the task has finished. Use it to cleanup temporary configuration created in [method _prepare].
func _cleanup() -> void:
	pass

## Called when the task data is being loaded. Use [member data] to retrieve data and push it to child [Control] nodes.
func _load() -> void:
	pass

## Called when the task data is being saved. Store any persistent information in the [member data] [Dictionary]. Any missing property will be filled from [member defaults].
func _store() -> void:
	pass

## Return the description of this task and its parameters.
func _get_task_info() -> PackedStringArray:
	return [
		"Task description",
		"Argument Name|Description",
	]

func load_data(new_data: Dictionary) -> void:
	data = new_data.merged(defaults)
	_load()

func store_data() -> Dictionary:
	_store()
	return data.merged(defaults)

static func create_instance(scene: String) -> Task:
	return load("res://Tasks/%s.tscn" % scene).instantiate()
