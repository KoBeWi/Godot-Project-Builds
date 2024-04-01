extends Control

@onready var time: Label = %Time
@onready var output_label: RichTextLabel = %OutputLabel

var task_text: String
var command: String
var arguments: PackedStringArray
var raw_text: String
var error: String

var program: ProgramInstance
var output: Array
var output_lines: Array[String]

var timer: float

signal success
signal fail

func _ready() -> void:
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
	
	var pipe_data := OS.execute_with_pipe(command, arguments)
	program = ProgramInstance.create_for_pipe(pipe_data)
	program.output_line.connect(output_line)
	program.start()

func output_line(line: String, is_error: bool):
	if is_error:
		output_label.push_color(Color.RED)
	
	output_label.append_text(line)
	
	if is_error:
		output_label.pop()
	
	output_label.append_text("\n")

func _process(delta: float) -> void:
	if program.is_running:
		timer += delta
		var intime := int(timer)
		time.text = "%02d:%02d:%02d" % [intime / 3600, intime / 60 % 60, intime % 60]
		return
	
	program.finalize()
	set_process(false)
	
	%Animation.queue_free()
	
	if program.result == 0:
		%Status.text = "Success"
		%Status.modulate = Color.GREEN
		%Code.modulate = Color.GREEN
		success.emit()
	else:
		%Status.text = "Fail"
		%Status.modulate = Color.RED
		%Code.modulate = Color.RED
		fail.emit()
	
	%Code.text = str(program.result)

func _on_command_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		## TODO: info, że się kopiuje
		DisplayServer.clipboard_set(raw_text)

func _exit_tree() -> void:
	if program.is_running:
		program.stop()
	program.finalize()

class ProgramInstance:
	var pid: int
	var stdio: FileAccess
	var stderr: FileAccess
	
	var is_running: bool
	var result: int
	var io_thread: Thread
	var err_thread: Thread
	
	signal output_line(line: String, is_error: bool)
	
	static func create_for_pipe(data: Dictionary) -> ProgramInstance:
		var instance := ProgramInstance.new()
		if data.is_empty():
			return instance
		
		instance.pid = data["pid"]
		instance.stdio = data["stdio"]
		instance.stderr = data["stderr"]
		instance.is_running = true
		
		return instance
	
	func start():
		io_thread = Thread.new()
		io_thread.start(stdio_read)
		
		err_thread = Thread.new()
		err_thread.start(stderr_read)
	
	func stdio_read():
		while is_running:
			if stdio.get_error() != OK or not OS.is_process_running(pid):
				break
			
			var line := stdio.get_line()
			output_line.emit.call_deferred(line, false)
		
		if not err_thread.is_alive():
			is_running = false
	
	func stderr_read():
		while is_running:
			if stderr.get_error() != OK or not OS.is_process_running(pid):
				break
			
			var line := stderr.get_line()
			output_line.emit.call_deferred(line, true)
		
		if not io_thread.is_alive():
			is_running = false
	
	func stop():
		if not is_running:
			return
		
		is_running = false
		OS.kill(pid)
		stdio.close()
		stderr.close()
	
	func finalize():
		io_thread.wait_to_finish()
		err_thread.wait_to_finish()

func toggle_output() -> void:
	output_label.visible = not output_label.visible
