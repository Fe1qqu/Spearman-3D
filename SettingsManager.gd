class_name SettingsManager
extends Node

const SETTINGS_PATH: String = "user://settings.cfg"

var mouse_sensitivity: float = 0.1

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var error: Error = config.load(SETTINGS_PATH)
	if error != OK:
		return
	
	mouse_sensitivity = config.get_value("controls", "mouse_sensitivity", mouse_sensitivity)

func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("controls", "mouse_sensitivity", mouse_sensitivity)
	config.save(SETTINGS_PATH)
