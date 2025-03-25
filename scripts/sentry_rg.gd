extends CharacterBody3D

enum State { IDLE, FOCUS }
var curState = State.IDLE

@onready var frame = $model/Node/bone/frame
@onready var head = $model/Node/bone
var target
var turn_speed = 8.0
var dead = false
var harm = 50

func _process(delta: float) -> void:
	frame.rotate_y(5 * delta) # Вращение "рамы", если нужно

	match curState:
		State.IDLE:
			pass
		State.FOCUS:
			if target:
				rotate_towards_target(delta)

func rotate_towards_target(delta: float) -> void:
	if not target: 
		return

	var global_target_pos = target.global_transform.origin
	var global_head_pos = head.global_transform.origin

	# Вектор направления от головы к цели
	var direction = (global_target_pos - global_head_pos).normalized()

	# Угол поворота относительно глобальной оси Y (не зависит от поворота CharacterBody3D)
	var target_yaw = atan2(-direction.x, -direction.z)

	# Интерполяция угла поворота головы по оси Y
	head.rotation.y = lerp_angle(head.rotation.y, target_yaw, turn_speed * delta)

	# Угол наклона (вверх-вниз) по оси Z (если нужно)
	var target_pitch = asin(direction.y)
	head.rotation.z = lerp_angle(head.rotation.z, target_pitch, turn_speed * delta)

func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		target = null
		curState = State.IDLE
