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
	apply_video_settings()
	apply_audio_settings()
	apply_gameplay_settings()

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

const VOLUME_CURVE = {
	"min_db": -40.0,
	"max_db": 0.0,
	"curve_exponent": 3.0 
}

func _linear_to_custom_volume(linear: float) -> float:
	var normalized = clamp(linear, 0.0, 1.0)
	print("Normalized: ", normalized)
	
	var curved = pow(normalized, 1.0/VOLUME_CURVE["curve_exponent"])
	print("Curved: ", curved)
	
	var db_range = VOLUME_CURVE["max_db"] - VOLUME_CURVE["min_db"]
	print("DB Range: ", db_range)
	
	var result = VOLUME_CURVE["min_db"] + curved * db_range
	print("Result: ", result)
	
	return result

func apply_video_settings() -> void:
	if Global.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)
		var screen_size = DisplayServer.screen_get_size()
		var window_size = resolution
		DisplayServer.window_set_position((screen_size - window_size) / 2)
	
	get_tree().root.content_scale_size = resolution

func apply_audio_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), _linear_to_custom_volume(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), _linear_to_custom_volume(sfx_volume)) 
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), _linear_to_custom_volume(music_volume)) 

func apply_gameplay_settings() -> void:
	get_tree().call_group("camera", "update_fov", field_of_vision)
	print("changed camera fov to", field_of_vision)
