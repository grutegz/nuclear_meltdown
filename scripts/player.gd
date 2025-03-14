extends CharacterBody3D

@export var sens = 0.5
@export var speed = 20
@export var jump_force = 5
@export var gravity = 10
@export var acceleration = 10

var offsetx := 0.0
var offsety := 0.0
var is_mouse_locked := true

func _ready() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
		# Движение игрока
		var input_dir = Vector3.ZERO
		if Input.is_action_pressed("w"):
				input_dir -= transform.basis.z
		if Input.is_action_pressed("s"):
				input_dir += transform.basis.z
		if Input.is_action_pressed("a"):
				input_dir -= transform.basis.x
		if Input.is_action_pressed("d"):
				input_dir += transform.basis.x
		
		var horizontal_velocity = velocity
		horizontal_velocity.y = 0
		horizontal_velocity = horizontal_velocity.lerp(input_dir.normalized() * speed, acceleration * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z

		if is_on_floor() and Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
		else:
			velocity.y -= gravity * delta

		move_and_slide()

		$cam.rotate_x(-offsety * delta * sens)
		rotate_y(-offsetx * delta * sens)
		$cam.rotation_degrees.x = clamp($cam.rotation_degrees.x, -90, 90)

		offsetx = 0.0
		offsety = 0.0

func _input(event: InputEvent) -> void:
		if Input.is_action_just_pressed("esc"):
				is_mouse_locked = not is_mouse_locked
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if is_mouse_locked else Input.MOUSE_MODE_VISIBLE)
		if event is InputEventMouseMotion and is_mouse_locked:
				offsetx = event.relative.x
				offsety = event.relative.y
