extends Control

const COLLAPSED_SIZE = 5

@onready var time: Label = %Time

var task_text: String
var command: String
var arguments: PackedStringArray
var raw_text: String
var error: String

var thread: Thread
var output: Array
var output_lines: Array[String]
var result: int

var timer: float

signal success
signal fail

func _ready() -> void:
	#var logpath := ProjectSettings.globalize_path("res://log.txt")
	#arguments.append(">")
	#arguments.append(logpath)
	#arguments.append("2>&1")
	#%Command.text = command + " " + " ".join(arguments) + " > " + logpath + " 2>&1"
	%TaskText.text = task_text
	
	if not error.is_empty():
		%Status.text = "Invalid"
		%Status.modulate = Color.RED
		%Command.text = error
		%Command.modulate = Color.RED
		%Code.text = ""
		%Animation.queue_free()
		fail.emit()
		set_process(false)
		return
	
	raw_text = command + " " + " ".join(arguments)
	%Command.text = raw_text.replace(Data.global_config["steam_password"], "*password*") ## TODO: nie hardkodować
	
	thread = Thread.new()
	thread.start(thread_method)

func thread_method():
	result = OS.execute(command, arguments, output, true)

func _process(delta: float) -> void:
	if thread.is_alive():
		timer += delta
		var intime := int(timer)
		time.text = "%02d:%02d:%02d" % [intime / 3600, intime / 60 % 60, intime % 60]
		return
	
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
			%OutputLabel.text = "\n".join(output_lines.slice(-COLLAPSED_SIZE - 1)).trim_suffix("\n")
			%ExpandButton.text %= output_lines.size() - 5

func expand_output() -> void:
	%OutputLabel.text = "\n".join(output_lines).trim_suffix("\n")
	%ExpandButton.hide()

func _on_command_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		## TODO: info, że się kopiuje
		DisplayServer.clipboard_set(raw_text)
