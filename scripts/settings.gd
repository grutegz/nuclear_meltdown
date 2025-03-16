extends Control

var config = ConfigFile.new()
const CONFIG_PATH = "res://settings.cfg"

var settings = {
	audio = {
		master_volume = 1.0,
		music_volume = 1.0,
		cfx_volume = 1.0
	},
	video = {
		fullscreen = false,
		resolution = Vector2i(1920, 1080),
		vsync = true
	},
	gameplay = {
		mouse_sensitivity = 0.5,
		field_of_vision = 0.7
	}
}

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	config.set_value("audio", "master_volume", settings.audio.master_volume)
	config.set_value("audio", "music_volume", settings.audio.music_volume)
	
	config.set_value("video", "fullscreen", settings.video.fullscreen)
	config.set_value("video", "resolution", settings.video.resolution)
	
	config.set_value("gameplay", "mouse_sensitivity", settings.gameplay.mouse_sensitivity)
	config.set_value("gameplay", "field_of_vision", settings.field_of_vision)
	
	config.save(CONFIG_PATH)

func load_settings() -> void:
	var err = config.load(CONFIG_PATH)
	if err != OK:
		print("No saved settings found, using defaults")
		return
	
	settings.audio.master_volume = config.get_value("audio", "master_volume", 1.0)
	
	settings.video.fullscreen = config.get_value("video", "fullscreen", false)
	apply_video_settings()
	
	settings.gameplay.mouse_sensitivity = config.get_value("gameplay", "mouse_sensitivity", 0.5)

func apply_video_settings() -> void:
	pass

func _on_go_back_pressed() -> void:
	queue_free()
	
