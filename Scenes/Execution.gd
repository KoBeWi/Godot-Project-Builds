extends Control

@onready var task_limbo: Node2D = %TaskLimbo
@onready var commands_container: VBoxContainer = %CommandsContainer

var task_count: int
var current_task: Task

class CommandItem: # TODO: usunąć
	var command: String
	var arguments: PackedStringArray
	
	func get_command() -> String:
		var ret := command
		ret = ret.replace("%godot%", "godot_console")
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
		task_instance.hide()
		commands_container.add_child(task_instance)
		
		task_instance._initialize(Data.project_path)
		task_instance.data = task["data"]
		task_instance._load()
		
		task_count += 1
	
	#item.arguments = ["a", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Build.zip", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.exe", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.pck"]
	
	next_command()

func next_command():
	if task_count == 0:
		return
	
	current_task = commands_container.get_child(0)
	current_task._prepare()
	
	var command := preload("res://Nodes/Command.tscn").instantiate()
	
	var command_text := current_task._get_command()
	command_text = command_text.replace("%godot%", "godot_console")
	command.command = command_text
	
	command.arguments = current_task._get_arguments()
	command.success.connect(on_success, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	commands_container.add_child(command)
	
	task_count -= 1

func on_success():
	current_task._cleanup()
	current_task.free()
	
	next_command()

func output_process():
	var output_file := FileAccess.open("res://log.txt", FileAccess.READ)
	
	while not output_end:
		print(output_file.get_line())
		
		OS.delay_msec(1)
