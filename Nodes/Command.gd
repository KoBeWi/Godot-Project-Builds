extends Control

@onready var time: Label = %Time
@onready var output_label: RichTextLabel = %OutputLabel

var task_text: String
var command: String
var arguments: PackedStringArray
var sensitive_strings: PackedStringArray

var raw_text: String
var error: String

var log_file: FileAccess
var program: ProgramInstance

var timer: float
var finish_code: int

signal success
signal fail

func _ready() -> void:
	%TaskText.text = task_text
	
	log_file.store_line("--- " + task_text + " ---\n")
	
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
	if sensitive_strings.is_empty():
		%Command.text = raw_text
	else:
		var command_text := raw_text
		for string in sensitive_strings:
			command_text = command_text.replace(string, "*".repeat(string.length()))
		%Command.text = command_text
	
	var pipe_data := OS.execute_with_pipe(command, arguments)
	program = ProgramInstance.create_for_pipe(pipe_data)
	program.output_line.connect(output_line)
	program.start()

func output_line(line: String, is_error: bool):
	log_file.store_line(line)
	
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
	finish_code = program.result

func _on_command_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		DisplayServer.clipboard_set(raw_text)
		
		var copied: Label = %Copied
		copied.position = %Command.get_local_mouse_position()
		copied.modulate.a = 1.0
		copied.show()
		
		var tween := copied.create_tween()
		tween.tween_property(copied, ^"modulate:a", 0.0, 0.5).set_delay(1)
		tween.tween_callback(copied.hide)
		

func _exit_tree() -> void:
	if not program:
		return
	
	if program.is_running:
		program.stop()
	program.finalize()

class ProgramInstance:
	var pid: int
	var stdio: FileAccess
	var stderr: FileAccess
	var finish_mutext: Mutex
	
	var is_running: bool
	var finalized: bool
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
		instance.finish_mutext = Mutex.new()
		instance.is_running = true
		
		return instance
	
	func start():
		io_thread = Thread.new()
		io_thread.start(pipe_read.bind(stdio))
		
		err_thread = Thread.new()
		err_thread.start(pipe_read.bind(stderr))
	
	func pipe_read(pipe: FileAccess):
		var is_err := pipe == stderr
		var buffer_empty: bool
		
		while is_running:
			if pipe.get_error() != OK or not OS.is_process_running(pid):
				break
			
			if buffer_empty:
				output_line.emit.call_deferred("", is_err)
			buffer_empty = false
			
			var line := pipe.get_line()
			if line.is_empty():
				buffer_empty = true
			else:
				output_line.emit.call_deferred(line, is_err)
		
		finish_mutext.lock()
		OS.delay_usec(1) # Prevents deadlock??
		
		var other: Thread
		if is_err:
			other = io_thread
		else:
			other = err_thread
		
		if not other.is_alive():
			is_running = false
		
		finish_mutext.unlock()
	
	func stop():
		if not is_running:
			return
		
		is_running = false
		OS.kill(pid)
		stdio.close()
		stderr.close()
	
	func finalize():
		if finalized:
			return
		
		io_thread.wait_to_finish()
		err_thread.wait_to_finish()
		result = OS.get_process_exit_code(pid)
		finalized = true

func toggle_output() -> void:
	output_label.visible = not output_label.visible

func copy_output() -> void:
	DisplayServer.clipboard_set(output_label.get_parsed_text())
