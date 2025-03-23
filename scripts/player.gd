extends CharacterBody3D

enum weapon {RL, SG, RG}
var recharge = [0.8,0.6,1.2]
var canFire = true

var curWeapon = 0
signal updateModel(model)

@export var sens = 0.3
@export var speed = 30
@export var jump_force = 25
@export var gravity = 10
@export var acceleration = 10

var stepPer = 7
var pellets = 5

var offsetx = 0.0
var offsety = 0.0
var horVel = Vector3.ZERO
var harm = 100
var vel = []
const damp = 2.5
var mergedVels = Vector3.ZERO

func _ready() -> void:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _physics_process(delta: float) -> void:
	var dir = Vector3.ZERO
	if Input.is_action_pressed("w"): dir -= transform.basis.z
	if Input.is_action_pressed("s"): dir += transform.basis.z
	if Input.is_action_pressed("a"): dir -= transform.basis.x
	if Input.is_action_pressed("d"): dir += transform.basis.x

	var target_hor_vel = dir.normalized() * speed
	horVel = horVel.lerp(target_hor_vel, acceleration * delta)
	apply_vels(delta)
	
	velocity = mergedVels + Vector3(horVel.x,0,horVel.z)
	velocity.y -=gravity*delta*50
	
	if horVel.length() > 0.5 and $steps.is_stopped():
		_on_steps_timeout()
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		vel.append(Vector3(0,jump_force,0))
	move_and_slide()

	$cam.rotate_x(-offsety * delta * sens)
	rotate_y(-offsetx * delta * sens)
	$cam.rotation_degrees.x = clamp($cam.rotation_degrees.x, -90, 90)

	offsetx = 0.0
	offsety = 0.0
	$UI/harm.value=harm
func apply_vels(delta):
	mergedVels = Vector3.ZERO
	for i in range(len(vel) - 1, -1, -1):
		vel[i] = vel[i] * exp(-damp * delta)  
		mergedVels += vel[i]
		if vel[i].length() < 0.01:
			vel.pop_at(i)
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot(curWeapon)
	if Input.is_action_just_pressed("act"):
		if $cam/ray.get_collider() and $cam/ray.get_collider().has_node("term1"): $cam/ray.get_collider().get_node("aud").play() 
	if event is InputEventMouseMotion:
		offsetx = event.relative.x
		offsety = event.relative.y
	if event.is_action_pressed("next"):
		curWeapon = (curWeapon + 1) % weapon.size()
		updateModel.emit(curWeapon)
	elif event.is_action_pressed("prev"):
		curWeapon = (curWeapon - 1 + weapon.size()) % weapon.size()
		updateModel.emit(curWeapon)
func shoot(type):
	if !canFire: return
	match type:
		weapon.RL:
			var rocket = preload("res://scenes/rocket.tscn").instantiate()
			add_sibling(rocket)
			rocket.global_transform = $cam/p.global_transform
			$rl.play()
		weapon.SG:
			#vel.append(transform.basis.z*10)
			
			for _i in range(pellets):
				var pellet = preload("res://scenes/pellet.tscn").instantiate()
				add_child(pellet)
				pellet.global_transform = $cam/p.global_transform
				pellet.global_rotation += pellet_offset(0.2)
			$sg.play()
		weapon.RG:
			var rail = preload("res://scenes/rail.tscn").instantiate()
			add_sibling(rail)
			rail.global_transform = $cam/p.global_transform
			$rg.play()
			
	$recharge.start(recharge[type])
	canFire=false
func _on_steps_timeout() -> void:
	if is_on_floor() and velocity.length() > 0.1:
		$steps.start(stepPer / max(velocity.length(), 5))
		$aud.play()
func pellet_offset(radius: float) -> Vector3:
	var point = Vector2.ONE.rotated(randf() * 2 * PI) * (randf() * radius)
	return Vector3(point.x, point.y, 0)
func _on_recharge_timeout() -> void:
	canFire=true
	$rech.play()
