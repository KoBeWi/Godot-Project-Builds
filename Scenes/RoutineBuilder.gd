extends Control

@onready var task_list: VBoxContainer = %TaskList
@onready var add_task: MenuButton = %AddTask

var routine: Dictionary
var task_to_test: Task

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
	update_paste()
	validate_routine_name()

func _create_task(idx: int):
	create_task(add_task.get_popup().get_item_metadata(idx))

func create_task(scene: String) -> Task:
	var container := preload("res://Nodes/TaskContainer.tscn").instantiate()
	task_list.add_child(container)
	container.copied.connect(update_paste)
	container.owner = self
	
	var task: Task = container.set_task_scene(scene)
	task.owner = self
	task._initialize()
	return task

func _back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")

func test_task(task: Task):
	task_to_test = task
	get_tree().current_scene = null
	get_parent().remove_child(self)

func _exit_tree() -> void:
	var routine_tasks: Array[Dictionary]
	var test_data: Dictionary
	
	for task: Task in task_list.get_children().map(func(container: Node) -> Task: return container.task):
		var task_data := Dictionary()
		task_data["scene"] = task.scene_file_path.get_file().get_basename()
		task_data["data"] = task.store_data()
		routine_tasks.append(task_data)
		
		if task == task_to_test:
			test_data = task_data
	
	routine["name"] = %RoutineName.text
	routine["tasks"] = routine_tasks
	Data.queue_save_local_config()
	
	if task_to_test:
		Data.current_routine = { "name": "Test", "tasks": [ test_data ]}
		queue_free()
		get_tree().change_scene_to_file("res://Scenes/Execution.tscn")
	
func paste_task() -> void:
	var task := Data.copied_task
	if task.is_empty():
		return
	
	var task_instance := create_task(task["scene"])
	task_instance.load_data(task["data"])

func update_paste():
	%PasteTask.disabled = Data.copied_task.is_empty()

func validate_routine_name():
	var valid := true
	for rout in Data.routines:
		if rout != routine and rout["name"] == %RoutineName.text:
			valid = false
			break
	
	if valid:
		get_tree().auto_accept_quit = true
		%RoutineName.modulate = Color.WHITE
		%Back.disabled = false
	else:
		get_tree().auto_accept_quit = false
		%RoutineName.modulate = Color.RED
		%Back.disabled = true
