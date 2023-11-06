extends Control

@onready var task_limbo: Node2D = %TaskLimbo
@onready var commands_container: VBoxContainer = %CommandsContainer

class CommandItem:
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
		var task_instance: Task = load(task["scene"]).instantiate()
		commands_container.add_child(task_instance)
		task_instance._initialize(Data.project_path)
		task_instance.data = task["data"]
		task_instance._load()
		
		var item := CommandItem.new()
		item.command = task_instance._get_command()
		item.arguments = task_instance._get_arguments()
		commands.append(item)
		
		task_instance.free()
	
	#item.arguments = ["a", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Build.zip", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.exe", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.pck"]
	
	next_command()

func next_command():
	if commands.is_empty():
		return
	
	var command_item: CommandItem = commands.pop_front()
	var command := preload("res://Nodes/Command.tscn").instantiate()
	command.command = command_item.get_command()
	command.arguments = command_item.arguments
	command.success.connect(on_success, CONNECT_ONE_SHOT)
	commands_container.add_child(command)

func on_success():
	next_command()

func output_process():
	var output_file := FileAccess.open("res://log.txt", FileAccess.READ)
	
	while not output_end:
		print(output_file.get_line())
		
		OS.delay_msec(1)
