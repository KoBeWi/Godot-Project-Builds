extends Control

@onready var template_container: VBoxContainer = %TemplateContainer
@onready var routine_container: VBoxContainer = %RoutineContainer

func _ready() -> void:
	for routine in Data.routines:
		add_routine(routine)
	
	for template in Data.templates:
		var temp := _add_template_pressed()
		temp.set_data(template)

func _exit_tree() -> void:
	save_templates()
	Data.save_routines()

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
	routine.set_routine_data(data)
	routine.connect_execute(exec_routine.bind(data))
	routine.connect_edit(edit_routine.bind(data))

func exec_routine(data: Dictionary):
	Data.current_routine = data
	get_tree().change_scene_to_file("res://Scenes/Execution.tscn")

func edit_routine(data: Dictionary):
	Data.current_routine = data
	get_tree().change_scene_to_file("res://Scenes/RoutineBuilder.tscn")

func duplicate_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["name"] = data["name"] + " (Copy)"
	dup.set_data(data)
	template_container.move_child(dup, template.get_index() + 1) # TODO: ustawić za inheritami

func inherit_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["inherit"] = data["name"]
	data["name"] = data["name"] + " (Inherited)"
	dup.set_data(data)
	template_container.move_child(dup, template.get_index() + 1)

func delete_template(template: Control):
	template.queue_free()
	save_templates()

func save_templates():
	Data.templates.assign(template_container.get_children().map(func(template: Control) -> Dictionary:
		return template.get_data()))
	
	Data.save_templates()
