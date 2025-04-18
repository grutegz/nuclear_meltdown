extends Camera3D
var rotation_speed := 0.5
var rotation_offset := Vector3(0.5, 1.0, 0.3)
var rotation_magnitude := 0.1

var time_passed := 0.0

func _ready():
	$FINAL_UI.visible = false

func _process(delta: float) -> void:
	time_passed += delta * rotation_speed
	
	var rot_x = sin(time_passed * rotation_offset.x) * rotation_magnitude
	var rot_y = cos(time_passed * rotation_offset.y) * rotation_magnitude
	var rot_z = sin(time_passed * rotation_offset.z) * rotation_magnitude
	
	$model.rotation = Vector3(rot_x, rot_y, rot_z)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
