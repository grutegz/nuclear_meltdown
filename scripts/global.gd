extends Node

var config_file = ConfigFile.new()
const CONFIG_PATH = "user://config.cfg"

var master_volume = 1.0
var music_volume = 1.0
var sfx_volume = 1.0

var fullscreen = false
var resolution = Vector2i(1280, 720)

var mouse_sensitivity = 1.0
var field_of_vision = 90

func _ready() -> void:
	var err = config_file.load(CONFIG_PATH)
	if err == OK:
		print("Config loaded successfully!!")
		master_volume = config_file.get_value("audio", "master_volume", 1.0)
		music_volume = config_file.get_value("audio", "music_volume", 1.0)
		sfx_volume = config_file.get_value("audio", "sfx_volume", 1.0)
		
		fullscreen = config_file.get_value("video", "fullscreen", false)
		resolution = config_file.get_value("video", "resolution", Vector2i(1280, 720))
		
		mouse_sensitivity = config_file.get_value("gameplay", "mouse_sensitivity", 1.0)
		field_of_vision = config_file.get_value("gameplay", "field_of_vision", 90)
		print("Mouse sensitivity", mouse_sensitivity)
	else:
		print("Config not found, falling back to the default values")
		save_config()

func save_config() -> void:
	print("saved MS as", mouse_sensitivity)
	config_file.set_value("audio", "master_volume", master_volume)
	config_file.set_value("audio", "music_volume", music_volume)
	config_file.set_value("audio", "sfx_volume", sfx_volume)
	
	config_file.set_value("video", "fullscreen", fullscreen)
	config_file.set_value("video", "resolution", resolution)
	
	config_file.set_value("gameplay", "mouse_sensitivity", mouse_sensitivity)
	config_file.set_value("gameplay", "field_of_vision", field_of_vision)
	
	config_file.save(CONFIG_PATH)

func save_and_quit() -> void:
	save_config()
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_and_quit()
