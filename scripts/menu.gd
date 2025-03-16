extends Control

var esc = true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_game_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	print("Button pressed!")
	var settings = preload("res://scenes/settings.tscn").instantiate()
	get_tree().root.add_child(settings)

func _on_exit_pressed() -> void:
	get_tree().quit()
