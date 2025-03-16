extends Control

func _on_start_game_pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	print("Button pressed!")
	var settings = preload("res://scenes/settings.tscn").instantiate()
	var settings_button = get_node("VBoxContainer/settings")
	settings_button.disabled = true
	get_tree().root.add_child(settings)
