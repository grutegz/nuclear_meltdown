extends Area3D

var target = null

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("player"):target = body
func _process(delta: float) -> void:
	if target:target.position.y+=delta*30
	$model/Node/plane.rotate_y(0.1)
func _on_body_exited(body: Node3D) -> void:
	if target: target.vel.append(Vector3.UP*3)
	target = null
