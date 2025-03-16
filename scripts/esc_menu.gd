extends Control

# когда вызовешь toggle_esc_menu, сцена издаст сигнал close_requested,
# который надо обработать в вызвавшей сцене
signal close_requested

func _input(event) -> void:
	if Input.is_action_just_pressed("esc"):
		emit_signal("close_requested")
		get_viewport().set_input_as_handled() # обязательный костыль чтобы две сцены одновременно нажатие клавиши не обработали

func _on_settings_pressed() -> void:
	var settings = preload("res://scenes/settings.tscn")
	add_child(settings.instantiate())

func _on_back_to_menu_pressed() -> void:
	# заглушка
	emit_signal("close_requested")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/menu.tscn")
	
