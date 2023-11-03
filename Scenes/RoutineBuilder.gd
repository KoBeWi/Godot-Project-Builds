extends Control

@onready var task_list: VBoxContainer = %TaskList
@onready var add_task: MenuButton = %AddTask

func _ready() -> void:
	add_task.get_popup().index_pressed.connect(create_task)
	
	# TODO: dać to w głównej scenie
	register_task("res://Tasks/ExportProject.tscn")

func register_task(scene: String):
	var instance: Task = load(scene).instantiate()
	add_task.get_popup().add_item(instance._get_task_name())
	instance.free()
	
	add_task.get_popup().set_item_metadata(-1, scene)

func create_task(idx: int):
	var scene: String = add_task.get_popup().get_item_metadata(idx)
	
	var container := preload("res://Nodes/TaskContainer.tscn").instantiate()
	task_list.add_child(container)
	
	var task: Task = container.set_task(load(scene))
	task._initialize("X:/Godot/Projects/ProjectBuilds/Testing/TestProject")
