extends VBoxContainer

@onready var group_scroll: ScrollContainer = %GroupScroll
@onready var group_container: VBoxContainer = %GroupContainer
@export var drop_target: Control

var groups: Dictionary[String, RoutineGroup]

var drag_placeholder: Control

func _ready() -> void:
	if not "groups" in Data.local_config: # compat
		var group := add_group("[Default Group]")
	else:
		for group_data in Data.local_config["groups"]:
			var group := add_group(group_data["name"])
			group.set_data(group_data)
	
	var default_group: RoutineGroup
	for routine in Data.routines:
		var target_group: RoutineGroup
		if not "group" in routine: # compat
			target_group = groups.values()[0]
		else:
			target_group = groups.get(routine["group"])
		target_group.add_routine(routine)
	
	drop_target.set_drag_forwarding(Callable(), _can_drop_group, _drop_group)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		if is_drop_data_valid(get_viewport().gui_get_drag_data()):
			drop_target.show()
	elif what == NOTIFICATION_DRAG_END:
		drop_target.hide()
		
		if drag_placeholder:
			drag_placeholder.free()
			drag_placeholder = null

func add_group(group_name: String) -> RoutineGroup:
	var group: RoutineGroup = preload("uid://dmjxmgu532xll").instantiate()
	group.changed.connect(_on_group_changed.bind(group))
	group.order_changed.connect(sync_and_save_routines, CONNECT_DEFERRED)
	
	var attempts := 0
	while group_name in groups:
		attempts += 1
		group_name = "New Group %d" % attempts
	
	var group_data := Data.create_routine_group(group_name)
	group.set_data(group_data)
	
	group_container.add_child(group)
	groups[group_name] = group
	return group

func duplicate_routine(data: Dictionary):
	data = data.duplicate(true)
	
	var new_name: String = data["name"]
	var suffix := " (Copy)"
	
	var unique: bool
	while not unique:
		unique = true
		for routine in Data.routines:
			if routine["name"] == new_name + suffix:
				suffix = " (Copy %d)" % (suffix.to_int() + 1)
				unique = false
	
	data["name"] = new_name + suffix
	#add_routine(data)
	
	sync_routines()
	Data.queue_save_local_config()

func sync_routines():
	var routines: Array[Dictionary]
	
	for group: RoutineGroup in groups.values():
		for routine: RoutinePreview in group.routines.get_children():
			var data := routine.data
			data["group"] = group.group_name.text
			routines.append(data)
	
	Data.routines.assign(routines)

func sync_groups():
	Data.routine_groups.assign(group_container.get_children().map(func(group: RoutineGroup) -> Dictionary:
		return group.data))

func sync_and_save_routines():
	sync_routines()
	Data.queue_save_local_config()

func _add_group_pressed() -> void:
	var group := add_group("New Group")
	
	await get_tree().process_frame
	
	group_scroll.ensure_control_visible(group)
	group.group_name.edit(false)
	group.group_name.select_all()

func _on_group_changed(group: RoutineGroup):
	var old_name: String = group.data["name"]
	var new_name := group.group_name.text
	
	if new_name != old_name:
		group.data["name"] = new_name
	
		groups.erase(old_name)
		groups[new_name] = group
		sync_routines()
	
	sync_groups()
	Data.queue_save_local_config()

func is_drop_data_valid(drop_data: Variant) -> bool:
	return drop_data is Dictionary and drop_data.get("type", "") == "routine_group"

func _can_drop_group(at_position: Vector2, drop_data: Variant) -> bool:
	if not is_drop_data_valid(drop_data):
		return false
	
	if not drag_placeholder:
		var drop_group: Control = drop_data["group"]
		
		drag_placeholder = preload("uid://b0mxp68ssl5j4").instantiate()
		drag_placeholder.self_modulate = drop_group.self_modulate
		group_container.add_child(drag_placeholder)
	
	var index := 0
	for group: Control in group_container.get_children():
		if not group.visible or not group is RoutineGroup:
			continue
		
		var group_pos := group.global_position - drop_target.global_position
		if group_pos.y < at_position.y:
			if drop_target.global_position.y + at_position.y < group.global_position.y + group.size.y * 0.5:
				index = maxi(group.get_index() - 1, 0)
			else:
				index = group.get_index() + 1
	
	group_container.move_child(drag_placeholder, index)
	drag_placeholder.show()
	
	return true

func _drop_group(at_position: Vector2, drop_data: Variant) -> void:
	if not drag_placeholder or not drag_placeholder.visible:
		return
	
	var group: RoutineGroup = drop_data["group"]
	group_container.move_child(group, drag_placeholder.get_index())
	
	sync_groups.call_deferred()
	Data.queue_save_local_config()
