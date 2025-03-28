extends CharacterBody3D


var sign = false



@onready var left_gun = $model/Node/left/cuboid2
@onready var right_gun = $model/Node/right/cuboid4
@onready var left_point = $model/Node/left/cuboid2/p
@onready var right_point = $model/Node/right/cuboid4/p

var rocket = preload("res://scenes/rocket.tscn")

enum State { IDLE, FOCUS, DEAD }
var curState = State.IDLE

var dead = false
var target: Node3D = null
var gravity = 10.0
var turn_speed = 8.0
@export var speed = 7
@export var acceleration = 3

var harm = 50
var horVel = Vector3.ZERO
var vel = []
const damp = 2.0
var mergedVels = Vector3.ZERO

var next_shot_left = true  # Для поочередной стрельбы
var can_shoot = false
var shoot_timer : Timer

func _ready():
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = 1.0  # Set initial wait time
	shoot_timer.one_shot = false
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _process(delta: float) -> void:
	match curState:
		State.IDLE:
			if harm <= 0:
				die()
		State.FOCUS:
			if target:
				rotate_towards_target(delta)
			# No shooting logic here.  Shooting handled by timer.
			if harm <= 0:
				die()
		State.DEAD:
			left_gun.rotation.z = lerp_angle(left_gun.rotation.z, -90, turn_speed * delta)
			right_gun.rotation.z = lerp_angle(right_gun.rotation.z, 90, turn_speed * delta)

	_update_wheel_speed()

func _physics_process(delta: float) -> void:
	if dead:
		return

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
	var target_rotation = atan2(-dir.x, -dir.z) + deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)

	# Наведение обеих пушек на цель
	left_gun.rotation.z = lerp_angle(left_gun.rotation.z, -dir.y - deg_to_rad(90), turn_speed * delta)
	right_gun.rotation.z = lerp_angle(right_gun.rotation.z, dir.y + deg_to_rad(90), turn_speed * delta)

func apply_vels(delta):
	mergedVels = Vector3.ZERO
	for i in range(len(vel) - 1, -1, -1):
		vel[i] = vel[i] * exp(-damp * delta)
		mergedVels += vel[i]
		if vel[i].length() < 0.01:
			vel.pop_at(i)

func _update_wheel_speed() -> void:
	var wheel_speed = horVel.length() * 0.005

func die():
	if dead: return
	dead = true
	curState = State.DEAD
	$soldierDies.play()
	speed = 0
	target = null
	$model/Node/left/head.queue_free()
	$model/Node/right/head.queue_free()

func shoot_rocket():
	if dead or curState == State.DEAD: return

	var point = left_point if next_shot_left else right_point
	var new_rocket = rocket.instantiate()
	add_sibling(new_rocket)

	new_rocket.global_transform = point.global_transform
	new_rocket.look_at(target.global_transform.origin, Vector3.UP)
	next_shot_left = not next_shot_left
	# No need to start $rech here; we are using a separate timer.
	$rl.play()


func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		target = body
		curState = State.FOCUS
		can_shoot = true
		shoot_timer.start()  # Start the timer when the player enters


func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		target = null
		curState = State.IDLE
		can_shoot = false
		shoot_timer.stop() # Stop the timer when the player exits


func _on_dist_body_entered(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		speed = 0

func _on_dist_body_exited(body: Node3D) -> void:
	if body.has_node("player") and not dead:
		speed = 7


func _on_shoot_timer_timeout():
	if can_shoot and target:
		shoot_rocket()
	# The timer automatically restarts because it is not one_shot.

# Remove the old _on_rech_timeout() function.
