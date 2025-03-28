extends Control

func _ready() -> void:
	$".".visible = false

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
