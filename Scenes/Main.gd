extends Control

@onready var template_container: VBoxContainer = %TemplateContainer
@onready var routine_container: VBoxContainer = %RoutineContainer

func _add_template_pressed() -> void:
	var template := preload("res://Nodes/PresetTemplate.tscn").instantiate()
	template_container.add_child(template)

func _add_routine_pressed() -> void:
	add_routine(Data.create_routine())

func add_routine(data: Dictionary):
	var routine := preload("res://Nodes/RoutinePreview.tscn").instantiate()
	routine_container.add_child(routine)
	routine.set_routine_data(data)
	routine.connect_edit(edit_routine.bind(data))

func edit_routine(data: Dictionary):
	Data.current_routine = data
	get_tree().change_scene_to_file("res://Scenes/RoutineBuilder.tscn")
