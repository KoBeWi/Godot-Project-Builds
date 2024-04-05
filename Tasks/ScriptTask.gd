extends Task

@export var script_name: String

func _get_command() -> String:
	return OS.get_executable_path()

func _get_arguments() -> PackedStringArray:
	var ret: PackedStringArray
	ret.append("--headless")
	
	if OS.has_feature("editor"):
		ret.append("--path")
		ret.append(Data.get_res_path())
	
	ret.append("--script")
	ret.append("res://Scripts/Tools/%s" % script_name)
	
	ret.append("--")
	return ret
