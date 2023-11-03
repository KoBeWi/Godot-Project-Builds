extends Control

class CommandItem:
	var command: String
	var arguments: PackedStringArray

var commands: Array[CommandItem]

var output_thread: Thread
var output_end: bool

func _ready() -> void:
	#FileAccess.open("res://log.txt", FileAccess.WRITE)
	#output_thread = Thread.new()
	#output_thread.start(output_process)
	
	var item := CommandItem.new()
	item.command = "godot_console"
	item.arguments = ["--path", "X:/Godot/Projects/ProjectBuilds/Testing/TestProject", "--headless", "--export-debug", "Windows Desktop", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.exe"]
	commands.append(item)
	
	item = CommandItem.new()
	item.command = "C:/Program Files/7-Zip/7zG.exe"
	item.arguments = ["a", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Build.zip", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.exe", "X:/Godot/Projects/ProjectBuilds/Testing/ExportTarget/Game.pck"]
	#commands.append(item)
	
	next_command()

func next_command():
	if commands.is_empty():
		return
	
	var command_item: CommandItem = commands.pop_front()
	var command := preload("res://Commands/Command.tscn").instantiate()
	command.command = command_item.command
	command.arguments = command_item.arguments
	command.success.connect(on_success, CONNECT_ONE_SHOT)
	%Commands.add_child(command)

func on_success():
	next_command()

func output_process():
	var output_file := FileAccess.open("res://log.txt", FileAccess.READ)
	
	while not output_end:
		print(output_file.get_line())
		
		OS.delay_msec(1)
