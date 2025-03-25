extends StaticBody3D

var target

func _process(delta: float) -> void:
	if target: target.harm+=delta

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_node("harm"): target = body



func _on_area_3d_body_exited(body: Node3D) -> void:
	target = null
