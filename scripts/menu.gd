extends Control

func _on_start_game_pressed() -> void:
	var main_scene = preload("res://scenes/main.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	queue_free()
