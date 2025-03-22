extends CharacterBody3D


enum State { IDLE, FOCUS }
var curState = State.IDLE

@onready var frame = $model/Node/bone/frame
@onready var head = $model/Node/bone
var target
var turn_speed = 8.0
func _process(delta: float) -> void:
	frame.rotate_y(5 * delta)

	match curState:
		State.IDLE:
			pass
		State.FOCUS:
			if target:
				rotate_towards_target(delta)
	

func rotate_towards_target(delta: float) -> void:
	if not target: return
	var dir = (target.global_transform.origin - global_transform.origin).normalized()
	var target_rotation = atan2(-dir.x, -dir.z) + deg_to_rad(90)
	head.rotation.y = lerp_angle(head.rotation.y, target_rotation, turn_speed * delta)
	head.rotation.z = lerp_angle(head.rotation.z, dir.y, turn_speed * delta)

func _on_vis_body_entered(body: Node3D) -> void:
	if body.has_node("player"):
		target = body
		curState = State.FOCUS

func _on_vis_body_exited(body: Node3D) -> void:
	if body.has_node("player"):
		target = null
		curState = State.IDLE
