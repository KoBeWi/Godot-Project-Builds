extends VBoxContainer

@onready var template_container: Control = %TemplateContainer

func _ready() -> void:
	for template in Data.templates:
		var temp := _add_template_pressed()
		temp.set_data(template)

func _add_template_pressed() -> Control:
	var template := preload("res://Nodes/PresetTemplate.tscn").instantiate()
	template_container.add_child(template)
	
	template.connect_duplicate(duplicate_template.bind(template))
	template.connect_inherit(inherit_template.bind(template))
	template.connect_delete(delete_template.bind(template))
	return template

func duplicate_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["name"] = Data.get_unique_name(Data.templates, data["name"], "(Copy %d)", 0)
	
	dup.set_data(data)
	sync_templates()
	Data.save_local_config()
	
	for other in template_container.get_children():
		if other.get_index() > template.get_index() and other.inherit != template.get_template_name():
			template_container.move_child(dup, other.get_index())
			break
	
	await get_tree().process_frame
	%TemplateScroll.ensure_control_visible(dup)

func inherit_template(template: Control):
	var dup := _add_template_pressed()
	var data: Dictionary = template.get_data().duplicate()
	data["inherit"] = data["name"]
	data["name"] = Data.get_unique_name(Data.templates, data["name"], "(Inherited %d)", 0)
	
	dup.set_data(data)
	sync_templates()
	Data.save_local_config()
	
	for other in template_container.get_children():
		if other.get_index() > template.get_index() and other.inherit != template.get_template_name():
			template_container.move_child(dup, other.get_index())
			break
	
	await get_tree().process_frame
	%TemplateScroll.ensure_control_visible(dup)

func delete_template(template: Control):
	template.queue_free()
	sync_templates()
	Data.queue_save_local_config()

func sync_templates():
	Data.templates.assign(template_container.get_children().map(func(template: Control) -> Dictionary:
		return template.get_data()))

func _exit_tree() -> void:
	if not Data.project_path.is_empty():
		sync_templates()
