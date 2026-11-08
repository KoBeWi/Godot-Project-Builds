class_name RoutineGroup extends PanelContainer

@export var group_name: LineEdit
@export var color_button: ColorPickerButton
@export var drop_target: Control
@export var drag_button: Button
@onready var routines: HFlowContainer = %Routines

var drag_placeholder: Control

var data: Dictionary

signal edit_request(routine: Dictionary)
signal exec_request(routine: Dictionary)
signal changed
signal order_changed

var rename_attempt: String

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		drag_button.set_drag_forwarding(_get_group_drag_data, Callable(), Callable())
		drop_target.set_drag_forwarding(Callable(), _can_drop_routine, _drop_routine)
	elif what == NOTIFICATION_DRAG_BEGIN:
		drop_target.show()
	elif what == NOTIFICATION_DRAG_END:
		show()
		
		drop_target.hide()
		if drag_placeholder:
			drag_placeholder.free()
			drag_placeholder = null

func set_data(d: Dictionary):
	data = d
	group_name.text = d["name"]
	self_modulate = d["color"]
	color_button.color = self_modulate

func color_changed(color: Color) -> void:
	self_modulate = color
	data["color"] = color
	changed.emit()

func create_routine() -> RoutinePreview:
	var routine := preload("uid://cctfsldanqcig").instantiate()
	routines.add_child(routine)
	return routine

func add_routine(routine_data: Dictionary):
	var routine := create_routine()
	routine.owner = self
	routine.set_routine_data(routine_data)
	routine.connect_duplicate(duplicate_routine.bind(routine_data))

func duplicate_routine(routine_data: Dictionary):
	routine_data = routine_data.duplicate(true)
	
	var new_name: String = routine_data["name"]
	var suffix := " (Copy)"
	
	var unique: bool
	while not unique:
		unique = true
		for routine in Data.routines:
			if routine["name"] == new_name + suffix:
				suffix = " (Copy %d)" % (suffix.to_int() + 1)
				unique = false
	
	routine_data["name"] = new_name + suffix
	add_routine(routine_data)
	
	order_changed.emit()

func _on_group_name_editing_toggled(toggled_on: bool) -> void:
	group_name.flat = not toggled_on
	if not toggled_on:
		rename_attempt = group_name.text
		group_name.text = data["name"]

func _on_group_name_text_submitted(new_text: String) -> void:
	changed.emit()

func _on_routine_created() -> void:
	var routine := Data.create_routine()
	routine.group = group_name.text
	add_routine(routine)

func _can_drop_routine(at_position: Vector2, drop_data: Variant) -> bool:
	if drop_data is not Dictionary or drop_data.get("type", "") != "routine":
		return false
	
	if not drag_placeholder:
		drag_placeholder = preload("uid://mp6y0fujathn").instantiate()
		routines.add_child(drag_placeholder)
	
	var index := 0
	for routine: Control in routines.get_children():
		if not routine.visible or not routine is RoutinePreview:
			continue
		
		var routine_pos := routine.global_position - drop_target.global_position
		if routine_pos.x < at_position.x and routine_pos.y < at_position.y:
			if drop_target.global_position.x + at_position.x < routine.global_position.x + routine.size.x * 0.5:
				index = maxi(routine.get_index() - 1, 0)
			else:
				index = routine.get_index() + 1
	
	routines.move_child(drag_placeholder, index)
	drag_placeholder.show()
	
	return true
	
func _drop_routine(at_position: Vector2, drop_data: Variant) -> void:
	if not drag_placeholder or not drag_placeholder.visible:
		return
	
	var routine: RoutinePreview = drop_data["routine"]
	if routine.get_parent() != routines:
		routine.reparent(routines, false)
	
	routines.move_child(routine, drag_placeholder.get_index())
	order_changed.emit()

func _on_drop_target_mouse_exited() -> void:
	if drag_placeholder:
		drag_placeholder.hide()

func _get_group_drag_data(from: Vector2) -> Dictionary:
	var preview: RoutineGroup = preload("uid://dmjxmgu532xll").instantiate()
	preview.set_data(data)
	preview.set_script(null)
	preview.reset_size()
	set_drag_preview(preview)
	
	hide()
	
	return {
		"type": "routine_group",
		"group": self,
	}
