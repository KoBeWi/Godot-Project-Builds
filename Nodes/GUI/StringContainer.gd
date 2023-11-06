extends ScrollContainer

@onready var strings: HBoxContainer = %Strings

var string_prefab: PackedScene

func _ready() -> void:
	string_prefab = Prefab.create(%StringPrefab)

func _add_string() -> void:
	var string := string_prefab.instantiate()
	strings.add_child(string)
