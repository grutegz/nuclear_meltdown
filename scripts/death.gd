extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()


func _on_go_back_pressed() -> void:
	_on_restart_pressed()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
