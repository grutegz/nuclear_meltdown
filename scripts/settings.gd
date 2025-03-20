extends Control

var config_file = ConfigFile.new()
const CONFIG_PATH = "res://config.cfg"

var config_obj = {
	audio = {
		master_volume = 1.0,
		music_volume = 1.0,
		sfx_volume = 1.0
	},
	video = {
		fullscreen = false,
		resolution = Vector2i(1280, 720)
	},
	gameplay = {
		mouse_sensitivity = 0.5,
		field_of_vision = 0.7
	}
}

# save setttings and close (probably shouldve made 2 buttons lul)
func _on_apply_and_go_back_pressed() -> void:
	apply_settings()
	queue_free()

@onready var screen_resolution_btn = $VBoxContainer/video_settings/screen_resolution as OptionButton
@onready var fullscreen_btn = $VBoxContainer/video_settings/fullscreen
@onready var mouse_sensitivity_btn = $VBoxContainer/video_settings/mouse_sensitivity
@onready var field_of_vision_btn = $VBoxContainer/video_settings/field_of_vision

const window_resolution_dict: Dictionary = {
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1600 x 900": Vector2i(1600, 900)
}

func _ready() -> void:
	# add resolution options to optionbutton
	screen_resolution_btn.item_selected.connect(on_screen_resolution_selected)
	for resolution_size_text in window_resolution_dict:
		screen_resolution_btn.add_item(resolution_size_text)

func on_screen_resolution_selected(index: int) -> void:
	config_obj.video.resolution = window_resolution_dict.values()[index]

func apply_settings() -> void:
	config_file.set_value("audio", "master_volume", config_obj.audio.master_volume)
	config_file.set_value("audio", "music_volume", config_obj.audio.music_volume)
	config_file.set_value("audio", "sfx_volume", config_obj.audio.sfx_volume)
	
	config_file.set_value("video", "fullscreen", config_obj.video.fullscreen)
	config_file.set_value("video", "resolution", config_obj.video.resolution)
	
	config_file.set_value("gameplay", "mouse_sensitivity", config_obj.gameplay.mouse_sensitivity)
	config_file.set_value("gameplay", "field_of_vision", config_obj.gameplay.field_of_vision)
	
	config_file.save(CONFIG_PATH)
	
	apply_video_settings()
	apply_gameplay_settings()
	apply_audio_settings()
	
func apply_video_settings() -> void:
	if config_obj.video.fullscreen:
		DisplayServer.window_set_size(config_obj.video.resolution)
		get_tree().root.content_scale_size = config_obj.video.resolution
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(config_obj.video.resolution)
		get_tree().root.content_scale_size = config_obj.video.resolution

	
func apply_audio_settings() -> void:
	pass
	
func apply_gameplay_settings() -> void:
	pass


func _on_fullscreen_pressed() -> void:
	config_obj.video.fullscreen = not config_obj.video.fullscreen
