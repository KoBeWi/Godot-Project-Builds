extends VBoxContainer

@onready var button: Button = %Button

@export var title: String:
	set(t):
		title = t
		
		if not is_node_ready():
			await ready
		button.text = title

@export var folded: bool:
	set(f):
		folded = f
		
		if not is_node_ready():
			await ready
		update_folding()

var style_box: StyleBox

func _ready() -> void:
	for node in get_children():
		if node is Control:
			custom_minimum_size.x = maxf(custom_minimum_size.x, node.get_combined_minimum_size().x)
	
	var spacer := Control.new()
	spacer.custom_minimum_size.y  = 4
	add_child(spacer)
	move_child(spacer, button.get_index() + 1)
	
	spacer = Control.new()
	spacer.custom_minimum_size.y  = 4
	add_child(spacer)

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		style_box = get_theme_stylebox(&"panel", &"Tree")

func toggle_folding():
	folded = not folded

func update_folding():
	if folded:
		button.icon = preload("res://Icons/ArrowDown.svg")
	else:
		button.icon = preload("res://Icons/ArrowUp.svg")
	
	for node in get_children():
		if not node is Control or node == button:
			continue
		node.visible = not folded

func _draw() -> void:
	draw_style_box(style_box, Rect2(Vector2(), size))
