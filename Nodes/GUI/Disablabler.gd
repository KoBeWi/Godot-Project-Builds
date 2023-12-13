extends Control

@onready var initial_mouse := mouse_filter
@onready var initial_focus := focus_mode

func set_noexist(noexist: bool):
	modulate.a = float(not noexist)
	process_mode = PROCESS_MODE_DISABLED if noexist else PROCESS_MODE_INHERIT
	mouse_filter = MOUSE_FILTER_IGNORE if noexist else initial_mouse
	focus_mode = Control.FOCUS_NONE if noexist else initial_focus
