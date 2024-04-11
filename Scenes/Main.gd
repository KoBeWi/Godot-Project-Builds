extends Control

@onready var template_container: Control = %TemplateContainer
@onready var routine_container: Control = %RoutineContainer
@onready var task_container: Control = %TaskContainer

var task_queue: Array[Dictionary]
var task_queue_index: int

func _ready() -> void:
	var config := ConfigFile.new()
	config.load(Data.project_path.path_join("project.godot"))
	
	%Title.text %= config.get_value("application", "config/name", "[unnamed]")
	if Data.from_plugin:
		%Back.hide()
	
	for routine in Data.routines:
		add_routine(routine)
	
	for template in Data.templates:
		var temp := _add_template_pressed()
		temp.set_data(template)
	
	task_queue.assign(Data.tasks.values())
	set_physics_process(false)
	
	if Data.first_load:
		for task in Data.static_initialize_tasks:
			task._initialize_project()
		Data.first_load = false
		
		if Data.initial_load:
			run_project_scan()
			Data.initial_load = false

func process_files(directory: String):
	for file in DirAccess.get_files_at(directory):
		for task in Data.static_initialize_tasks:
			task._process_file(directory.path_join(file))
	
	for dir in DirAccess.get_directories_at(directory):
		if not dir.begins_with("."):
			process_files(directory.path_join(dir))

func _physics_process(delta: float) -> void:
	var task := task_queue[task_queue_index]
	
	var preview := preload("res://Nodes/TaskPreview.tscn").instantiate()
	preview.task = task
	task_container.add_child(preview)
	
	task_queue_index += 1
	if task_queue_index == task_queue.size():
		set_physics_process(false)
		task_queue.clear()

func _exit_tree() -> void:
	if Data.project_path.is_empty():
		return
	sync_templates()

func _add_template_pressed() -> Control:
	var template := preload("res://Nodes/PresetTemplate.tscn").instantiate()
	template_container.add_child(template)
	
	template.connect_duplicate(duplicate_template.bind(template))
	template.connect_inherit(inherit_template.bind(template))
	template.connect_delete(delete_template.bind(template))
	return template

func _add_routine_pressed() -> void:
	add_routine(Data.create_routine())

func add_routine(data: Dictionary):
	var routine := preload("res://Nodes/RoutinePreview.tscn").instantiate()
	routine_container.add_child(routine)
	routine.owner = self
	routine.set_routine_data(data)
	routine.connect_execute(exec_routine.bind(data))
	routine.connect_edit(edit_routine.bind(data))
	routine.connect_duplicate(duplicate_routine.bind(data))

func exec_routine(data: Dictionary):
	Data.current_routine = data
	get_tree().change_scene_to_file("res://Scenes/Execution.tscn")

func edit_routine(data: Dictionary):
	Data.current_routine = data
	get_tree().change_scene_to_file("res://Scenes/RoutineBuilder.tscn")

func duplicate_routine(data: Dictionary):
	data = data.duplicate(true)
	data["name"] += " (Copy)"
	add_routine(data)
	
	sync_routines()
	Data.queue_save_local_config()

func duplicate_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["name"] = Data.get_unique_name(Data.templates, data["name"], "(Copy %d)", 0)
	
	dup.set_data(data)
	sync_templates()
	Data.save_local_config()
	
	for other in template_container.get_children():
		if other.get_index() > template.get_index() and other.inherit != template.get_template_name():
			template_container.move_child(dup, other.get_index())
			break
	
	await get_tree().process_frame
	%TemplateScroll.ensure_control_visible(dup)

func inherit_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["inherit"] = data["name"]
	data["name"] = Data.get_unique_name(Data.templates, data["name"], "(Inherited %d)", 0)
	
	dup.set_data(data)
	sync_templates()
	Data.save_local_config()
	
	for other in template_container.get_children():
		if other.get_index() > template.get_index() and other.inherit != template.get_template_name():
			template_container.move_child(dup, other.get_index())
			break
	
	await get_tree().process_frame
	%TemplateScroll.ensure_control_visible(dup)

func delete_template(template: Control):
	template.queue_free()
	sync_templates()
	Data.queue_save_local_config()

func sync_routines():
	Data.routines.assign(routine_container.get_children().map(func(routine: Control) -> Dictionary:
		return routine.data))

func sync_templates():
	Data.templates.assign(template_container.get_children().map(func(template: Control) -> Dictionary:
		return template.get_data()))

func go_back() -> void:
	sync_templates()
	Data.save_local_config()
	Data.project_path = ""
	get_tree().change_scene_to_file("res://Scenes/ProjectManager.tscn")

func run_project_scan() -> void:
	for task in Data.static_initialize_tasks:
		task._begin_project_scan()
	
	process_files(Data.project_path)
	
	for task in Data.static_initialize_tasks:
		task._end_project_scan()
	
	%ScanFinished.show()
	%ScanFinished.modulate.a = 1.0
	
	var tween := create_tween()
	tween.tween_property(%ScanFinished, ^"modulate:a", 0.0, 0.5).set_delay(0.5)
	tween.tween_callback(%ScanFinished.hide)

func tab_changed(tab: int) -> void:
	if tab == 2 and not task_queue.is_empty():
		set_physics_process(true)

func open_logs() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://BuildLogs"))
