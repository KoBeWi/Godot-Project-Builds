extends Control

@onready var task_limbo: Node2D = %TaskLimbo
@onready var commands_container: VBoxContainer = %CommandsContainer

var current_task_index: int
var current_task: Task

class CommandItem: # TODO: usunąć
	var command: String
	var arguments: PackedStringArray
	
	func get_command() -> String:
		var ret := command
		ret = ret.replace("%godot%", Data.get_godot_path())
		return ret

var commands: Array[CommandItem]

var output_thread: Thread
var output_end: bool

func _ready() -> void:
	#FileAccess.open("res://log.txt", FileAccess.WRITE)
	#output_thread = Thread.new()
	#output_thread.start(output_process)
	
	var routine := Data.get_current_routine()
	for task in routine["tasks"]:
		var task_instance: Task = load("res://Tasks/%s.tscn" % task["scene"]).instantiate()
		task_limbo.add_child(task_instance)
		
		task_instance._initialize(Data.project_path)
		task_instance.data = task["data"]
		task_instance._load()
	
	#item.arguments = ["a", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Build.zip", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.exe", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.pck"]
	
	next_command()

func next_command():
	if current_task_index == task_limbo.get_child_count():
		return
	
	current_task = task_limbo.get_child(current_task_index)
	current_task._prepare()
	
	var command := preload("res://Nodes/Command.tscn").instantiate()
	command.task_text = current_task._get_execute_string()
	
	var command_text := current_task._get_command()
	command_text = command_text.replace("%godot%", Data.get_godot_path())
	command.command = command_text
	
	command.arguments = current_task._get_arguments()
	command.success.connect(on_success, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	command.fail.connect(on_success, CONNECT_ONE_SHOT | CONNECT_DEFERRED) ## TODO inny
	commands_container.add_child(command)
	
	current_task_index += 1

func on_success():
	current_task._cleanup()
	next_command()

#func output_process():
	#var output_file := FileAccess.open("res://log.txt", FileAccess.READ)
	#
	#while not output_end:
		#print(output_file.get_line())
		#
		#OS.delay_msec(1)
