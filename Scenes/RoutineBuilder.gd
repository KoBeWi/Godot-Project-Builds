extends Control

@onready var task_list: VBoxContainer = %TaskList
@onready var add_task: MenuButton = %AddTask

var routine: Dictionary

func _ready() -> void:
	routine = Data.get_current_routine()
	%RoutineName.text = routine["name"]
	
	for task in Data.tasks.values():
		add_task.get_popup().add_item(task["name"])
		add_task.get_popup().set_item_metadata(-1, task["scene"])
	
	for task: Dictionary in routine["tasks"]:
		var task_instance := create_task(task["scene"])
		task_instance.load_data(task["data"])
	
	add_task.get_popup().index_pressed.connect(_create_task)

func _create_task(idx: int):
	create_task(add_task.get_popup().get_item_metadata(idx))

func create_task(scene: String) -> Task:
	var container := preload("res://Nodes/TaskContainer.tscn").instantiate()
	task_list.add_child(container)
	
	var task: Task = container.set_task_scene(scene)
	task.owner = self
	task._initialize()
	return task

func _back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func _exit_tree() -> void:
	var routine_tasks: Array[Dictionary]
	
	for task: Task in task_list.get_children().map(func(container: Node) -> Task: return container.task):
		var task_data := Dictionary()
		task_data["scene"] = task.scene_file_path.get_file().get_basename()
		task_data["data"] = task.store_data()
		routine_tasks.append(task_data)
	
	routine["name"] = %RoutineName.text
	routine["tasks"] = routine_tasks
	Data.queue_save_local_config()
