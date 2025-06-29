extends Control

var esc = true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_game_pressed() -> void:
	if Global.first_time:
		pass
	Global.first_time = false
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	print("Button pressed!")
	var settings = preload("res://scenes/settings.tscn").instantiate()
	get_tree().root.add_child(settings)

func _on_exit_pressed() -> void:
	Global.save_and_quit()

func _process(delta: float) -> void:
	$SubViewportContainer/SubViewport/model.rotate_y(delta)


func _on_gthb_pressed() -> void:
	OS.shell_open("https://github.com/grutegz/nuclear_meltdown")
func _on_bst_pressed() -> void:
	OS.shell_open("https://boosty.to/grutegz")


func _on_button_pressed() -> void:
	#open_html_in_browser("AUTORS.htm")
	pass
func open_html_in_browser(file_path: String):
	var absolute_path = ProjectSettings.globalize_path(file_path)
	if FileAccess.file_exists(absolute_path):
		OS.shell_open(absolute_path)
	else:
		print("Файл не найден: ", absolute_path)
