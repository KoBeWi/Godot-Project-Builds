extends Control

@onready var task_list: VBoxContainer = %TaskList
@onready var add_task: MenuButton = %AddTask

var routine: Dictionary

func _ready() -> void:
	routine = Data.get_current_routine()
	
	for task in Data.tasks:
		add_task.get_popup().add_item(task["name"])
		add_task.get_popup().set_item_metadata(-1, task["scene"])
	
	add_task.get_popup().index_pressed.connect(create_task)

func create_task(idx: int):
	var scene: String = add_task.get_popup().get_item_metadata(idx)
	
	var container := preload("res://Nodes/TaskContainer.tscn").instantiate()
	task_list.add_child(container)
	
	var task: Task = container.set_task(load(scene))
	task._initialize("X:/Godot/Projects/ProjectBuilds/Testing/TestProject")

func _back_pressed() -> void:
	
	
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
