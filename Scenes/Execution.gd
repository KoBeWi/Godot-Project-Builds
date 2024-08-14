extends Control

@onready var task_limbo: Node2D = %TaskLimbo
@onready var commands_container: VBoxContainer = %CommandsContainer
@onready var error_container: Control = %Errors

var current_task_index: int
var current_task: Task
var task_in_progress: bool
var task_error: String

var on_fail: int
var sensitive_strings: PackedStringArray
var log_file: FileAccess
var fail_count: int

var separator_prefab: PackedScene

func _ready() -> void:
	separator_prefab = Prefab.create(%Separator)
	
	var errors: PackedStringArray
	
	var routine := Data.get_current_routine()
	on_fail = routine["on_fail"]
	
	for task in routine["tasks"]:
		var task_instance := Task.create_instance(task["scene"])
		task_limbo.add_child(task_instance)
		
		task_instance._initialize()
		task_instance.load_data(task["data"])
		
		if not task_instance._prevalidate():
			errors.append("%s: %s" % [task_instance._get_execute_string(), task_instance.error_message])
	
	if not errors.is_empty():
		%ErrorsParent.show()
		%Delay.hide()
		
		for error in errors:
			var label := Label.new()
			label.text = error
			label.modulate = Color.RED
			error_container.add_child(label)
		
		finish()
		return
	
	await get_tree().create_timer(1).timeout
	%Delay.hide()
	
	DirAccess.make_dir_recursive_absolute("user://BuildLogs")
	var logs: Array[String]
	logs.assign(DirAccess.get_files_at("user://BuildLogs"))
	if logs.size() >= 10:
		logs.sort_custom(func(log1: String, log2: String):
			return FileAccess.get_modified_time("user://BuildLogs".path_join(log1)))
		
		for logg in logs.slice(9):
			DirAccess.remove_absolute("user://BuildLogs".path_join(logg))
	
	for setting in Data.sensitive_settings:
		var string: String = Data.global_config.get(setting, "")
		if string.is_empty():
			string = Data.local_config.get(setting, "")
		
		if not string.is_empty():
			sensitive_strings.append(string)
	
	var filename := "user://" + ("BuildLogs/Log-%s.log" % Time.get_datetime_string_from_system()).replace(":", "-")
	log_file = FileAccess.open(filename, FileAccess.WRITE)
	next_command()

func next_command():
	if current_task_index == task_limbo.get_child_count():
		finish()
		return
	log_file.store_line("")
	
	current_task = task_limbo.get_child(current_task_index)
	var command := preload("res://Nodes/Command.tscn").instantiate()
	command.log_file = log_file
	
	if current_task._validate():
		task_in_progress = true
		current_task._prepare()
	else:
		command.error = current_task.error_message
	
	command.task_text = current_task._get_execute_string()
	command.command = current_task._get_command()
	command.arguments = current_task._get_arguments()
	if current_task.has_sensitive_data:
		command.sensitive_strings = sensitive_strings
	
	command.success.connect(task_finished.bind(true), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	command.fail.connect(task_finished.bind(false), CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	commands_container.add_child(command)
	
	current_task_index += 1

func task_finished(success: bool):
	current_task._cleanup()
	task_in_progress = false
	
	var command := commands_container.get_child(-1)
	var intime: int = command.timer
	log_file.store_line("\n> Finished with code %d, time: %02d:%02d:%02d." % [command.finish_code, intime / 3600, intime / 60 % 60, intime % 60])
	log_file.flush()
	
	commands_container.add_child(separator_prefab.instantiate())
	
	if not success:
		fail_count += 1
		if on_fail == 0:
			finish()
			return
	
	next_command()

func finish():
	if Data.auto_exit:
		get_tree().quit(fail_count)
		return
	
	%Button.show()
	
	var total_time: float
	for command in commands_container.get_children():
		if &"timer" in command:
			total_time += command.timer
	
	var intime := int(total_time)
	%Time.text %= [intime / 3600, intime / 60 % 60, intime % 60]
	%Time.show()

func go_back() -> void:
	get_tree().change_scene_to_packed(Data.main)

func _exit_tree() -> void:
	if task_in_progress:
		current_task._cleanup()
