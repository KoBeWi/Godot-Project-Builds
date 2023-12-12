extends ScrollContainer

@onready var strings: HBoxContainer = %Strings

var string_prefab: PackedScene

func _ready() -> void:
	string_prefab = Prefab.create(%StringPrefab)

func _add_string() -> LineEdit:
	var string := string_prefab.instantiate()
	strings.add_child(string)
	return string

func get_strings() -> PackedStringArray:
	return strings.get_children().map(func(line_edit: LineEdit) -> String: return line_edit.text)

func set_strings(strins: PackedStringArray):
	for s in strins:
		var strin := _add_string()
		strin.text = s
