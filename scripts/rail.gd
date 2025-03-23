extends RayCast3D


const damage = 30
func _process(delta: float) -> void:
	if get_collider() is CharacterBody3D and get_collider().has_node("harm"):
		var collider = get_collider()
		if collider.has_node("harm"):collider.harm-=damage
	queue_free()
