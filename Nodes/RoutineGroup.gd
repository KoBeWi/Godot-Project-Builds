class_name RoutineGroup extends PanelContainer

@export var group_name: LineEdit
@onready var routines: HFlowContainer = %Routines

var data: Dictionary

signal edit_request(routine: Dictionary)
signal exec_request(routine: Dictionary)
signal group_renamed

func set_data(d: Dictionary):
	data = d
	group_name.text = d["name"]
	self_modulate = d["color"]

func color_changed(color: Color) -> void:
	self_modulate = color
	data["color"] = color

func create_routine() -> RoutinePreview:
	var routine := preload("uid://cctfsldanqcig").instantiate()
	routines.add_child(routine)
	return routine

func add_routine(routine_data: Dictionary):
	var routine := create_routine()
	routine.owner = self
	routine.set_routine_data(routine_data)
	routine.connect_duplicate(duplicate_routine.bind(routine_data))

func duplicate_routine(routine: Dictionary):
	pass

func _on_group_name_editing_toggled(toggled_on: bool) -> void:
	group_name.flat = not toggled_on

func _on_group_name_text_submitted(new_text: String) -> void:
	group_renamed.emit(new_text)

func _on_routine_created() -> void:
	var routine := Data.create_routine()
	routine.group = group_name.text
	add_routine(routine)
