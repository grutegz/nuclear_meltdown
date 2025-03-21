extends StaticBody3D

var open = false

const OPEN_R = Vector3(5, 2, 0)
const OPEN_L = Vector3(-1, 2, 0)
const SPEED = 5.0

@onready var door_r: Node3D = $colr
@onready var door_l: Node3D = $coll

var closed_r: Vector3
var closed_l: Vector3
func _ready() -> void:
	closed_r = door_r.position
	closed_l = door_l.position

func _process(delta: float) -> void:
	var target_r = OPEN_R if open else closed_r
	var target_l = OPEN_L if open else closed_l

	door_r.position = door_r.position.lerp(target_r, 1 - exp(-SPEED * delta))
	door_l.position = door_l.position.lerp(target_l, 1 - exp(-SPEED * delta))


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.has_node("player"): open = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_node("player"): open = true
