extends CharacterBody3D

@onready var frame = $model/Node/body/cuboid2
@onready var hand = $model/Node/body/hand
@onready var point = $model/Node/body/hand

enum State { IDLE, FOCUS }
var curState = State.IDLE

var target: Node3D = null
var gravity = 10.0
var turn_speed = 8.0
@export var speed = 10
@export var acceleration = 5

var harm = 70
var horVel = Vector3.ZERO
var vel = []
const damp = 2.0
var mergedVels = Vector3.ZERO

func _process(delta: float) -> void:
	frame.rotate_y(5 * delta)

	match curState:
		State.IDLE:
			pass
		State.FOCUS:
			if target:
				rotate_towards_target(delta)
	_update_wheel_speed()
	
func _physics_process(delta: float) -> void:
	apply_vels(delta)
	var dir = Vector3.ZERO
	if curState == State.FOCUS:
		dir = (target.global_transform.origin - global_transform.origin).normalized()
	
	var target_hor_vel = dir * speed
	horVel = horVel.lerp(target_hor_vel, acceleration * delta)

	velocity = mergedVels + Vector3(horVel.x, 0, horVel.z)
	velocity.y -= gravity * delta*50

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
	if body.has_node("player"):
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player"):
		target = null
		curState = State.IDLE

func _on_dist_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		speed = 0

func _on_dist_body_exited(body: Node3D) -> void:
	if body.has_node("player"):
		speed = 20
