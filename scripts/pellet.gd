extends RayCast3D

func _process(delta: float) -> void:
	if is_colliding():
		print("im colliding with: ",get_collider())
		queue_free()
	if $Timer.is_stopped(): queue_free()
