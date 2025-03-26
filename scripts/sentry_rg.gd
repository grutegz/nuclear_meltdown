extends CharacterBody3D

enum State { IDLE, FOCUS, DEAD }
var curState = State.IDLE

@onready var frame = $model/Node/bone/frame
@onready var head = $model/Node/bone
@onready var p = $model/Node/bone/cuboid/p
@onready var laser = $model/Node/bone/cuboid/laser
var rail = preload("res://scenes/rail.tscn")  # Изменено на ресурс, а не инстанс
var target: Node3D = null
var turn_speed = 6.0
var dead = false
var harm = 50
var can_shoot = false

func _process(delta: float) -> void:
	match curState:
		State.IDLE:
			laser.visible = false
			frame.rotate_y(5 * delta)
			if harm <= 0:
				die()
		State.FOCUS:
			frame.rotate_y(5 * delta)
			laser.visible = false
			if target:
				laser.visible = true
				rotate_towards_target(delta)
				if can_shoot:
					shoot()
			if harm <= 0:
				die()
		State.DEAD:
			
			head.rotation.z = lerp_angle(head.rotation.z, -deg_to_rad(70), turn_speed * delta)
			

func die():
	laser.visible = false
	curState = State.DEAD
	dead = true
	head.get_node("head").queue_free()
	$soldierDies.play()

func rotate_towards_target(delta: float) -> void:
	if not target: return
	var global_target_pos = target.global_transform.origin
	var global_head_pos = head.global_transform.origin
	var direction = (global_target_pos - global_head_pos).normalized()
	var target_yaw = atan2(-direction.x, -direction.z)
	head.rotation.y = lerp_angle(head.rotation.y, target_yaw+deg_to_rad(90), turn_speed * delta)
	var target_pitch = asin(direction.y)
	head.rotation.z = lerp_angle(head.rotation.z, target_pitch, turn_speed * delta)

func shoot():
	if dead or curState != State.FOCUS: return
	$rg.play()
	var new_rail = rail.instantiate()
	new_rail.damage = 20
	add_child(new_rail)
	new_rail.global_transform = p.global_transform
	#new_rail.rotate_y(-deg_to_rad(90))
	can_shoot = false
	$rech.start()

func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		$rech.start()
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		target = null
		curState = State.IDLE


func _on_rech_timeout() -> void:
	can_shoot = true
