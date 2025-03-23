extends RayCast3D

const MAX_DAMAGE = 5.0
const MAX_DISTANCE = 50.0
func _process(delta: float) -> void:
	if get_collider() is CharacterBody3D and get_collider().has_node("harm"):
		var distance = global_transform.origin.distance_to(get_parent().global_transform.origin)
		var damage = MAX_DAMAGE * (1.0 - clamp(distance / MAX_DISTANCE, 0.0, 1.0))
		get_collider().harm -= damage
		queue_free()
	if $Timer.is_stopped():
		queue_free()
