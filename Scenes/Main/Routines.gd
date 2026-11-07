extends VBoxContainer

@onready var group_scroll: ScrollContainer = %GroupScroll
@onready var group_container: VBoxContainer = %GroupContainer

var groups: Dictionary[String, RoutineGroup]

func _ready() -> void:
	if not "groups" in Data.local_config: # compat
		var group := add_group("[Default Group]")
	else:
		for group_data in Data.local_config["groups"]:
			var group := add_group(group_data["name"])
	
	var default_group: RoutineGroup
	for routine in Data.routines:
		var target_group: RoutineGroup
		if not "group" in routine: # compat
			target_group = groups.values()[0]
		else:
			target_group = groups.get(routine["group"])
		target_group.add_routine(routine)
	
func add_group(group_name: String) -> RoutineGroup:
	var group: RoutineGroup = preload("uid://dmjxmgu532xll").instantiate()
	group.group_renamed.connect(_on_group_renamed.bind(group))
	
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

func _add_group_pressed() -> void:
	var group := add_group("New Group")
	
	await get_tree().process_frame
	
	group_scroll.ensure_control_visible(group)
	group.group_name.edit(false)
	group.group_name.select_all()

func _on_group_renamed(new_name: String, group: RoutineGroup):
	var old_name: String = group.data["name"]
	group.data["name"] = new_name
	
	groups.erase(old_name)
	groups[new_name] = group
	
	sync_groups()
	sync_routines()
	Data.queue_save_local_config()
