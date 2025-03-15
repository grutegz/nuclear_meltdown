extends CharacterBody3D

enum weapon {RL, AR}

@export var sens = 0.5
@export var speed = 20
@export var jump_force = 5
@export var gravity = 10
@export var acceleration = 10

var stepPer = 7

var offsetx = 0.0
var offsety = 0.0
var esc = true

func _ready() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var dir = Vector3.ZERO
	if Input.is_action_pressed("w"):dir -= transform.basis.z
	if Input.is_action_pressed("s"):dir += transform.basis.z
	if Input.is_action_pressed("a"):dir -= transform.basis.x
	if Input.is_action_pressed("d"):dir += transform.basis.x
	
	var horVel = velocity
	horVel.y = 0
	horVel = horVel.lerp(dir.normalized() * speed, acceleration * delta)
	velocity.x = horVel.x
	velocity.z = horVel.z


	if horVel.length()>0.5 and $steps.is_stopped(): _on_steps_timeout()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
	velocity.y -= gravity * delta

	move_and_slide()

	$cam.rotate_x(-offsety * delta * sens)
	rotate_y(-offsetx * delta * sens)
	$cam.rotation_degrees.x = clamp($cam.rotation_degrees.x, -90, 90)

	offsetx = 0.0
	offsety = 0.0

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		esc = not esc
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if esc else Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("shoot"):
		shoot(0)
	if event is InputEventMouseMotion and esc:
		offsetx = event.relative.x
		offsety = event.relative.y
func shoot(type):
	match type:
		weapon.RL:
			var rocket = preload("res://scenes/rocket.tscn").instantiate()
			rocket.global_transform = $cam/p.global_transform
			add_sibling(rocket)

func _on_steps_timeout() -> void:
	if is_on_floor() and velocity.length() > 0.1:
		print(velocity.length())
		$steps.start(stepPer / max(velocity.length(), 5))
		$aud.play()
