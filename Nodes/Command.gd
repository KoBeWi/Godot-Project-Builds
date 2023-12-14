extends Control

const COLLAPSED_SIZE = 5

var task_text: String
var command: String
var arguments: PackedStringArray

var thread: Thread
var output: Array
var output_lines: Array[String]
var result: int

signal success
signal fail

func _ready() -> void:
	#var logpath := ProjectSettings.globalize_path("res://log.txt")
	#arguments.append(">")
	#arguments.append(logpath)
	#arguments.append("2>&1")
	#%Command.text = command + " " + " ".join(arguments) + " > " + logpath + " 2>&1"
	%TaskText.text = task_text
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
			%Code.modulate = Color.GREEN
			success.emit()
		else:
			%Status.text = "Fail"
			%Status.modulate = Color.RED
			%Code.modulate = Color.RED
			fail.emit()
		
		%Code.text = str(result)
		
		await get_tree().process_frame
		%Output.show()
		if output[0].is_empty():
			%OutputLabel.text = "No Output"
		else:
			output_lines.assign(output[0].split("\n"))
			if output_lines.size() <= COLLAPSED_SIZE:
				expand_output()
			else:
				%OutputLabel.text = "\n".join(output_lines.slice(-COLLAPSED_SIZE - 1))
				%ExpandButton.text %= output_lines.size() - 5

func expand_output() -> void:
	%OutputLabel.text = "\n".join(output_lines)
	%ExpandButton.hide()

func _on_command_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		DisplayServer.clipboard_set(%Command.text)
