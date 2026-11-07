class_name RoutinePreview extends PanelContainer

@export var drag: Button

var data: Dictionary

func _ready() -> void:
	drag.set_drag_forwarding(_get_routine_drag_data, Callable(), Callable())

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		show()

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

func refresh_parent():
	owner.sync_routines()
	Data.queue_save_local_config()
	
	for child in get_parent().get_children():
		child.update_buttons()

func _on_execute_pressed() -> void:
	Data.current_routine = data
	get_tree().change_scene_to_file("uid://dqm1wdopgkdkp")

func _on_edit_pressed() -> void:
	Data.current_routine = data
	get_tree().change_scene_to_file("uid://dbb72q773nirj")

func _get_routine_drag_data(from: Vector2) -> Dictionary:
	var preview: Control = duplicate()
	preview.set_script(null)
	preview.reset_size()
	set_drag_preview(preview)
	
	hide()
	
	return {
		"type": "routine",
		"routine": self,
	}
