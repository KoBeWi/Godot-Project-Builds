extends MarginContainer

@onready var task_container: Control = %TaskContainer

var task_queue: Array[Dictionary]
var task_queue_index: int

func _ready() -> void:
	task_queue.assign(Data.tasks.values())
	set_physics_process(false)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree() and not task_queue.is_empty():
			set_physics_process(true)

func _physics_process(delta: float) -> void:
	var task := task_queue[task_queue_index]
	
	var preview := preload("res://Nodes/TaskPreview.tscn").instantiate()
	preview.task = task
	task_container.add_child(preview)
	
	task_queue_index += 1
	if task_queue_index == task_queue.size():
		set_physics_process(false)
		task_queue.clear()
