class_name RoutineGroup extends PanelContainer

@export var group_name: LineEdit
@onready var routines: HFlowContainer = %Routines

func color_changed(color: Color) -> void:
	self_modulate = color

func create_routine() -> RoutinePreview:
	var routine := preload("uid://cctfsldanqcig").instantiate()
	routines.add_child(routine)
	return routine

func add_routine(data: Dictionary):
	var routine := create_routine()
	routine.owner = self
	routine.set_routine_data(data)
	#routine.connect_execute(exec_routine.bind(data))
	#routine.connect_edit(edit_routine.bind(data))
	#routine.connect_duplicate(duplicate_routine.bind(data))

func _on_group_name_editing_toggled(toggled_on: bool) -> void:
	group_name.flat = not toggled_on
