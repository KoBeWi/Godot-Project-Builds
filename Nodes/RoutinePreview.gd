class_name RoutinePreview extends PanelContainer

@onready var move_left: Button = %MoveLeft
@onready var move_right: Button = %MoveRight

var data: Dictionary

func _ready() -> void:
	update_buttons.call_deferred()

func set_routine_data(d: Dictionary):
	data = d
	%Name.text = data["name"]
	if data["tasks"].is_empty():
		%TaskCount.text = "No Tasks"
		%Execute.disabled = true
		return
	
	%TaskCount.text %= data["tasks"].size()
	
	var task_list: PackedStringArray
	for task in data["tasks"]:
		var task_info: Dictionary = Data.tasks[task["scene"]]
		task_list.append(task_info["name"])
	
	%TaskList.text = "\n".join(task_list)

func connect_duplicate(target: Callable):
	%Duplicate.pressed.connect(target)

func delete() -> void:
	Data.routines.erase(data)
	Data.queue_save_local_config()
	queue_free()

func update_buttons():
	move_left.disabled = get_index() == 0
	move_right.disabled = get_index() == get_parent().get_child_count() - 1

func refresh_parent():
	owner.sync_routines()
	Data.queue_save_local_config()
	
	for child in get_parent().get_children():
		child.update_buttons()

func _on_move_left_pressed() -> void:
	get_parent().move_child(self, get_index() - 1)
	refresh_parent()

func _on_move_right_pressed() -> void:
	get_parent().move_child(self, get_index() + 1)
	refresh_parent()

func _on_execute_pressed() -> void:
	Data.current_routine = data
	get_tree().change_scene_to_file("uid://dqm1wdopgkdkp")

func _on_edit_pressed() -> void:
	Data.current_routine = data
	get_tree().change_scene_to_file("uid://dbb72q773nirj")
