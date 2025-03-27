extends Control

var config_file = ConfigFile.new()
const CONFIG_PATH = "user://config.cfg"

var Local = {
	"resolution": Vector2i(1920, 1080),
	"fullscreen": false,
	"mouse_sensitivity": 1.0,
	"field_of_vision": 90,
	"master_volume": 1.0,
	"music_volume": 1.0,
	"sfx_volume": 1.0
}

@onready var screen_resolution_btn = $VBoxContainer/video_settings/screen_resolution as OptionButton
@onready var fullscreen_btn = $VBoxContainer/video_settings/fullscreen 
@onready var sensitivity_sldr = $VBoxContainer/Gameplay/sensitivity_sldr as HSlider
@onready var fov_sldr = $VBoxContainer/Gameplay/fov_sldr as HSlider

@onready var master_sldr = $VBoxContainer/sound_settings/master_sldr as HSlider
@onready var music_sldr = $VBoxContainer/sound_settings/music_sldr as HSlider
@onready var sfx_sldr = $VBoxContainer/sound_settings/sfx_sldr as HSlider

const window_resolution_dict: Dictionary = {
	"640 x 480": Vector2i(640, 480),
	"800 x 600": Vector2i(800, 600),
	"1024 x 768": Vector2i(1024, 768),
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1280 x 800": Vector2i(1280, 800),
	"1280 x 1024": Vector2i(1280, 1024),
	"1360 x 768": Vector2i(1360, 768),
	"1366 x 768": Vector2i(1366, 768),
	"1440 x 900": Vector2i(1440, 900),
	"1536 x 864": Vector2i(1536, 864),
	"1600 x 900": Vector2i(1600, 900),
	"1600 x 1200": Vector2i(1600, 1200),
	"1680 x 1050": Vector2i(1680, 1050),
	"1920 x 1080": Vector2i(1920, 1080),
	"1920 x 1200": Vector2i(1920, 1200),
	"2048 x 1080": Vector2i(2048, 1080),
	"2560 x 1080": Vector2i(2560, 1080),
	"2560 x 1440": Vector2i(2560, 1440),
	"2560 x 1600": Vector2i(2560, 1600),
	"3440 x 1440": Vector2i(3440, 1440),
	"3840 x 1600": Vector2i(3840, 1600),
	"3840 x 2160": Vector2i(3840, 2160),
	"4096 x 2160": Vector2i(4096, 2160)
}

const VOLUME_CURVE = {
	"min_db": -40.0,
	"max_db": 0.0,
	"curve_exponent": 3.0 
}

func _db_to_linear(db: float) -> float:
	return inverse_lerp(VOLUME_CURVE["min_db"], VOLUME_CURVE["max_db"], db)

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

func _ready() -> void:
	setup_sensitivity_slider()
	setup_resolution_button()
	setup_sound_slider()
	screen_resolution_btn.item_selected.connect(on_screen_resolution_selected)

func _on_master_sldr_value_changed(value: float):
	var db = _linear_to_custom_volume(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	Local.master_volume = value

func _on_music_sldr_value_changed(value: float):
	var db = _linear_to_custom_volume(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db) 
	Local.music_volume = value

func _on_sfx_sldr_value_changed(value: float):
	var db = _linear_to_custom_volume(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
	Local.sfx_volume = value

func setup_sound_slider() -> void:
	master_sldr.value = Global.master_volume
	music_sldr.value = Global.music_volume
	sfx_sldr.value = Global.sfx_volume

func setup_sensitivity_slider() -> void:
	sensitivity_sldr.min_value = 0.0
	sensitivity_sldr.max_value = 2.0
	sensitivity_sldr.step = 0.01
	sensitivity_sldr.rounded = false
	sensitivity_sldr.value = log(Global.mouse_sensitivity) / log(10) + 1.0

func setup_resolution_button() -> void:
	screen_resolution_btn.clear()
	for resolution_text in window_resolution_dict.keys():
		screen_resolution_btn.add_item(resolution_text)

	var target_res = Global.resolution
	var resolution_index = window_resolution_dict.values().find(target_res)
	if resolution_index != -1:
		screen_resolution_btn.select(resolution_index)
	
	fullscreen_btn.button_pressed = Global.fullscreen
	sensitivity_sldr.value = Global.mouse_sensitivity
	fov_sldr.value = Global.field_of_vision

func on_screen_resolution_selected(index: int) -> void:
	Local.resolution = window_resolution_dict.values()[index]

func _on_apply_and_go_back_pressed() -> void:
	Global.resolution = Local.resolution
	Global.field_of_vision = Local.field_of_vision
	Global.master_volume = Local.master_volume
	Global.sfx_volume = Local.sfx_volume
	Global.music_volume = Local.music_volume
	Global.mouse_sensitivity = Local.mouse_sensitivity
	Global.field_of_vision = Local.field_of_vision
	apply_video_settings()
	apply_audio_settings()
	apply_gameplay_settings()
	queue_free()

func apply_video_settings() -> void:
	if Global.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Global.resolution)
		var screen_size = DisplayServer.screen_get_size()
		var window_size = Global.resolution
		DisplayServer.window_set_position((screen_size - window_size) / 2)
	
	get_tree().root.content_scale_size = Global.resolution

func apply_audio_settings() -> void:
	pass

func apply_gameplay_settings() -> void:
	get_tree().call_group("camera", "update_fov", Global.field_of_vision)
	print("changed camera fov to", Global.field_of_vision)

func _on_fullscreen_pressed() -> void:
	Global.fullscreen = not Global.fullscreen

func _on_sensitivity_sldr_value_changed(value: float) -> void:
	var real_sensitivity = pow(10, value - 1.0)
	Local.mouse_sensitivity = clamp(real_sensitivity, 0.1, 10.0)
	print("set globan MS to", real_sensitivity)

func _on_fov_sldr_value_changed(value: float) -> void:
	print("works")
	Local.field_of_vision = value;
