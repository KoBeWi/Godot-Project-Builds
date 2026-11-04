extends HBoxContainer

func _ready() -> void:
	register_global_setting(%GlobalGodot, "godot_path", OS.get_executable_path())
	register_global_setting(%ExecutionDelay, "execution_delay", 2)
	
	register_global_setting(%SteamCMD, "steam_cmd_path", "")
	register_global_setting(%SteamUsername, "steam_username", "")
	register_global_setting(%SteamPassword, "steam_password", "", true)
	
	register_global_setting(%PipelineBuilderPath, "pipeline_builder_path", "")
	register_global_setting(%GOGUsername, "gog_username", "")
	register_global_setting(%GOGPassword, "gog_password", "", true)
	
	register_global_setting(%BuildPatchToolPath, "build_patch_tool_path", "")
	register_global_setting(%EpicOrganizationID, "epic_organization_id", "")
	register_global_setting(%EpicClientID, "epic_client_id", "")
	register_global_setting(%EpicClientSecret, "epic_client_secret", "", true)
	register_global_setting(%EpicClientSecretEnvVar, "epic_client_secret_env_var", "")
	
	register_global_setting(%ItchButlerPath, "itch_butler_path", "")
	register_global_setting(%ItchUsername, "itch_username", "")
	
	register_local_setting(%LocalGodot, "godot_path", "")
	
	register_local_setting(%EpicProductID, "epic_product_id", "")
	register_local_setting(%EpicArtifactID, "epic_artifact_id", "")
	register_local_setting(%EpicCloudDir, "epic_cloud_dir", "")
	
	register_local_setting(%ItchGameName, "itch_game_name", "")
	register_local_setting(%ItchDefaultChannel, "itch_default_channel", "")
	register_local_setting(%ItchVersionFile, "itch_version_file", "")
	
	%ConfigPath.text = Data.local_config_file
	%ConfigPath.path_changed.connect(config_path_updated, CONNECT_DEFERRED)
	
	update_plugin_status()

func register_global_setting(control: Control, setting: String, default: Variant, sensitive := false):
	register_setting(control, setting, default, Data.global_config, on_global_setting_changed, sensitive)

func register_local_setting(control: Control, setting: String, default: Variant, sensitive := false):
	register_setting(control, setting, default, Data.local_config, on_local_setting_changed, sensitive)

func register_setting(control: Control, setting: String, default: Variant, config: Dictionary, callback: Callable, sensitive: bool):
	if setting in config:
		control.text = config[setting]
	else:
		config[setting] = default
	
	var sygnał
	var binds: Array
	
	sygnał = control.get(&"path_changed")
	if sygnał:
		binds.append("")
	else:
		sygnał = control.get(&"text_changed")
		if not sygnał:
			sygnał = control.get(&"value_changed")
	
	assert(not sygnał.is_null())
	
	binds.append_array([control, setting])
	sygnał.connect(callback.bindv(binds))
	
	if sensitive and not setting in Data.sensitive_settings:
		Data.sensitive_settings.append(setting)

func on_global_setting_changed(dummy, control: Control, setting: String):
	Data.global_config[setting] = control.text
	Data.queue_save_global_config()

func on_local_setting_changed(dummy, control: Control, setting: String):
	Data.local_config[setting] = control.text
	Data.queue_save_local_config()

func update_plugin_status():
	var plugin_file := ConfigFile.new()
	plugin_file.load(Data.get_res_path().path_join("addons/ProjectBuilder/plugin.cfg"))
	var current_version: String = plugin_file.get_value("plugin", "version", "0.0")
	
	if plugin_file.load(Data.project_path.path_join("addons/ProjectBuilder/plugin.cfg")) == OK:
		var project_version: String = plugin_file.get_value("plugin", "version", "0.0")
		var old: bool
		
		for i in current_version.get_slice_count("."):
			if current_version.get_slice(".", i).to_int() > project_version.get_slice(".", i).to_int():
				old = true
				break
		
		if old:
			%PluginStatus.text = "Plugin outdated."
			%PluginStatus.modulate = Color.YELLOW
			%InstallPlugin.disabled = false
		else:
			%PluginStatus.text = "Plugin installed and up-to-date."
			%PluginStatus.modulate = Color.GREEN
			%InstallPlugin.disabled = true
	else:
		%PluginStatus.text = "Plugin not installed."
		%PluginStatus.modulate = Color.RED
		%InstallPlugin.disabled = false

func _on_install_plugin_pressed() -> void:
	var source_path := Data.get_res_path().path_join("addons/ProjectBuilder")
	var target_path := Data.project_path.path_join("addons/ProjectBuilder")
	DirAccess.make_dir_recursive_absolute(target_path)
	
	for file in DirAccess.get_files_at(source_path):
		DirAccess.copy_absolute(source_path.path_join(file), target_path.path_join(file))
	
	update_plugin_status()

func config_path_updated():
	var old_path := Data.local_config_file
	var show_error = func(text: String):
		%ConfigPath.text = old_path
		%PathError.dialog_text = text
		%PathError.popup_centered()
	
	var new_path: String = %ConfigPath.text.path_join("project_builds_config.txt")
	var new_path_abs := Data.project_path.path_join(new_path)
	if new_path == old_path:
		return
	
	%ConfigPath.text = new_path
	
	var exists: bool
	if FileAccess.file_exists(new_path_abs):
		exists = true
	
	var error := OK
	var old_empty: bool
	if exists:
		old_empty = true
		for value in Data.local_config.values():
			if value is String or value is Array:
				if not value.is_empty():
					old_empty = false
					break
		
		if old_empty:
			OS.move_to_trash(Data.project_path.path_join(old_path))
	else:
		error = DirAccess.rename_absolute(Data.project_path.path_join(old_path), new_path_abs)
	
	if error == OK:
		var settings_path := Data.project_path.path_join("project.godot")
		var settings := FileAccess.get_file_as_string(settings_path).split("\n")
		const setting_line := "_project_builder_config_path="
		
		var replaced: bool
		for i in settings.size():
			if settings[i].begins_with(setting_line):
				settings[i] = "%s\"%s\"" % [setting_line, new_path]
				replaced = true
				break
		
		if not replaced:
			settings.insert(10, "%s\"%s\"" % [setting_line, new_path])
		
		var saver := FileAccess.open(settings_path, FileAccess.WRITE)
		if not saver:
			show_error.call("Failed to save project settings, error %d." % FileAccess.get_open_error())
			return
		else:
			saver.store_string("\n".join(settings))
			saver.close()
		
		Data.local_config_file = new_path
		%ConfigPath.validate()
		
		if exists: # Reload config if changed to existing file.
			%PathError.dialog_text = "Config file already exists in that directory.\nIt will be used instead and the Project Builder will reload."
			if old_empty:
				%PathError.dialog_text += "\n" + "The old config file was empty, it will be deleted."
			%PathError.popup_centered()
			
			await %PathError.visibility_changed
			Data.load_project(Data.project_path)
			get_tree().reload_current_scene()
	else:
		show_error.call("Failed to move config file, error %d." % error)
