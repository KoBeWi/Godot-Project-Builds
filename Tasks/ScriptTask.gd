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
	ret.append(get_script_path())
	
	ret.append("--")
	return ret

func _prevalidate() -> bool:
	if script_name.is_empty():
		error_message = "ScriptTask's script name is empty. Assign it in the scene."
		return false
	
	var script_path := get_script_path()
	if not ResourceLoader.exists(script_path):
		error_message = "The provided ScriptTask's script does not exist at expected path: \"%s\"." % script_path
		return false
	
	return true

func get_script_path() -> String:
	return "res://Scripts/Tools/%s" % script_name
