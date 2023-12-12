extends Control

var command: String
var arguments: PackedStringArray

var thread: Thread
var output: Array
var result: int

signal success
signal fail

func _ready() -> void:
	#var logpath := ProjectSettings.globalize_path("res://log.txt")
	#arguments.append(">")
	#arguments.append(logpath)
	#arguments.append("2>&1")
	#%Command.text = command + " " + " ".join(arguments) + " > " + logpath + " 2>&1"
	%Command.text = command + " " + " ".join(arguments)
	
	thread = Thread.new()
	thread.start(thread_method)

func thread_method():
	result = OS.execute(command, arguments, output, true)

func _process(delta: float) -> void:
	if not thread.is_alive():
		thread.wait_to_finish()
		set_process(false)
		
		%Animation.queue_free()
		
		if result == 0:
			%Status.text = "Success"
			%Status.modulate = Color.GREEN
			%Code.text = str(result)
			%Code.modulate = Color.GREEN
			success.emit()
		else:
			%Status.text = "Fail"
			%Status.modulate = Color.RED
			%Code.text = str(result)
			%Code.modulate = Color.RED
			fail.emit()
		
		await get_tree().process_frame
		%Output.show()
		if output[0].is_empty():
			%Output.text = "No Output"
		else:
			%Output.text = output[0]


func _on_command_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		DisplayServer.clipboard_set(%Command.text)
