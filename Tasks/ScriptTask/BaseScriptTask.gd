extends SceneTree

var argument_list: PackedStringArray
var arguments: Dictionary

func add_expected_argument(name: String, description: String):
	argument_list.append("e|%s|%s" % [name, description])

func add_optional_argument(name: String, description: String):
	argument_list.append("o|%s|%s" % [name, description])

func add_variadic_argument(name: String, description: String):
	argument_list.append("v|%s|%s" % [name, description])

func fetch_arguments() -> bool:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty() and args[0] == "--help":
		print("Argument list:")
		for argument in argument_list:
			var type := argument.get_slice("|", 0)
			
			print("%s (%s) - %s" % [
				argument.get_slice("|", 1),
				"expected" if type == "e" else "optional" if type == "o" else "variadic",
				argument.get_slice("|", 2),
			])
		
		quit(OK)
		return false
	
	for i in argument_list.size():
		var argument := argument_list[i]
		var argument_name := argument.get_slice("|", 1)
		
		if argument.begins_with("e") and i >= args.size():
			printerr("Missing expected argument: %s" % argument_name)
			quit(ERR_INVALID_PARAMETER)
			return false
		
		if i >= args.size():
			if argument.begins_with("v"):
				arguments[argument_name] = []
			else:
				arguments[argument_name] = ""
			continue
		
		if argument.begins_with("v"):
			arguments[argument_name] = args.slice(i)
		else:
			arguments[argument_name] = args[i]
	
	return true
