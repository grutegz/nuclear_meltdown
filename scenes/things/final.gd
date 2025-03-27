@tool
extends Camera3D
# Параметры плавного вращения
var rotation_speed := 0.5  # Скорость вращения
var rotation_offset := Vector3(0.5, 1.0, 0.3)  # Разные коэффициенты для осей
var rotation_magnitude := 0.1  # Амплитуда вращения

var time_passed := 0.0


func _process(delta: float) -> void:
	time_passed += delta * rotation_speed
	
	var rot_x = sin(time_passed * rotation_offset.x) * rotation_magnitude
	var rot_y = cos(time_passed * rotation_offset.y) * rotation_magnitude
	var rot_z = sin(time_passed * rotation_offset.z) * rotation_magnitude
	
	$model.rotation = Vector3(rot_x, rot_y, rot_z)
