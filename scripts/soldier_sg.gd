extends CharacterBody3D

@onready var frame = $model/Node/body/cuboid2
@onready var hand = $model/Node/body/hand
@onready var point = $model/Node/body/hand/p

enum State { IDLE, FOCUS, DEAD }
var curState = State.IDLE

var sign = true

var dead = false
var target: Node3D = null
var gravity = 10.0
var turn_speed = 8.0
@export var speed = 15
@export var acceleration = 5

var harm = 30
var horVel = Vector3.ZERO
var vel = []
const damp = 2.0
var mergedVels = Vector3.ZERO

func _process(delta: float) -> void:
	match curState:
		State.IDLE:
			frame.rotate_y(5 * delta)
			if harm <= 0:
				curState = State.DEAD
				dead = true
				$soldierDies.play()
		State.FOCUS:
			if target:
				rotate_towards_target(delta)
			frame.rotate_y(5 * delta)
			if $rech.is_stopped():$rech.start(0.6)
			if harm <= 0:
				curState = State.DEAD
				dead = true
				$soldierDies.play()
		State.DEAD:
			hand.rotation.z = lerp_angle(hand.rotation.z, 0, turn_speed * delta)
			frame.rotation.y = lerp_angle(frame.rotation.y, 0, turn_speed * delta)
			if $model/Node/body.has_node("head"):
				$model/Node/body/head.queue_free()
			if sign: get_parent().get_parent().get_parent().get_parent().get_node("player").get_node("UI").get_node("sign").visible = true

	_update_wheel_speed()

func _physics_process(delta: float) -> void:
	apply_vels(delta)
	var dir = Vector3.ZERO
	if curState == State.FOCUS:
		dir = (target.global_transform.origin - global_transform.origin).normalized()
	
	var target_hor_vel = dir * speed
	horVel = horVel.lerp(target_hor_vel, acceleration * delta)

	velocity = mergedVels + Vector3(horVel.x, 0, horVel.z)
	velocity.y -= gravity * delta * 50

	move_and_slide()

func rotate_towards_target(delta: float) -> void:
	if not target: return
	var dir = (target.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = atan2(-dir.x, -dir.z) - deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)
	hand.rotation.z = lerp_angle(hand.rotation.z, -dir.y - deg_to_rad(30), turn_speed * delta)

func apply_vels(delta):
	mergedVels = Vector3.ZERO
	for i in range(len(vel) - 1, -1, -1):
		vel[i] = vel[i] * exp(-damp * delta)  
		mergedVels += vel[i]
		if vel[i].length() < 0.01:
			vel.pop_at(i)

func _update_wheel_speed() -> void:
	var wheel_speed = horVel.length() * 0.005
	$wheel1.material_override.set_shader_parameter("amount", wheel_speed)
	$wheel2.material_override.set_shader_parameter("amount", wheel_speed)
	$wheel3.material_override.set_shader_parameter("amount", wheel_speed)
	$wheel4.material_override.set_shader_parameter("amount", wheel_speed)

func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player") and !dead:
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player") and !dead:
		target = null
		curState = State.IDLE

func _on_dist_body_entered(body: Node3D) -> void:
	if body.has_node("player") and !dead:
		speed = 0

func _on_dist_body_exited(body: Node3D) -> void:
	if body.has_node("player") and !dead:
		speed = 15

const pellets = 5
func _on_rech_timeout() -> void:
	shoot()

func pellet_offset(radius: float) -> Vector3:
	var point = Vector2.ONE.rotated(randf() * 2 * PI) * (randf() * radius)
	return Vector3(point.x, point.y, 0)
func shoot():
	if dead or curState==State.IDLE: return
	for _i in range(pellets):
		var pellet = preload("res://scenes/pellet.tscn").instantiate()
		add_child(pellet)
		pellet.global_transform = point.global_transform
		pellet.global_rotation += pellet_offset(0.2)
	$sg.play()
