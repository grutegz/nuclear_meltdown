extends CharacterBody3D

@onready var frame = $model/Node/cuboid2
@onready var hand = $model/Node/bone
@onready var point = $model/Node/bone/p

enum State { IDLE, FOCUS }
var curState = State.IDLE

var target: Node3D = null
var gravity = 10.0
var turn_speed = 8.0
var speed = 20

func _process(delta: float) -> void:
	frame.rotate_y(5 * delta)

	match curState:
		State.IDLE:
			pass
		State.FOCUS:
			if target:
				rotate_towards_target(delta)
	velocity.y -= gravity
	move_and_slide()

func rotate_towards_target(delta: float) -> void:
	if not target: return
	var dir= (target.global_transform.origin - global_transform.origin)
	dir=dir.normalized()
	var targetr = atan2(-dir.x,-dir.z) - deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, targetr, turn_speed * delta)
	hand.rotation.z= lerp_angle(hand.rotation.z,-dir.y-deg_to_rad(30), turn_speed*delta)
	velocity=-Vector3(basis.x.x,0,basis.x.z).normalized()*speed*delta *0x1F

func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player"):
		target = null
		curState = State.IDLE




func _on_dist_body_entered(body: Node3D) -> void:
	if body.has_node("player"):speed = 0
func _on_dist_body_exited(body: Node3D) -> void:
	if body.has_node("player"):speed = 20
