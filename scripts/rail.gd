extends RayCast3D

const damage = 30

func _ready() -> void:

	set_hit_back_faces(true)
	set_collide_with_areas(true)
	set_collide_with_bodies(true)

func _process(delta: float) -> void:
	var collisions = []
	force_raycast_update()

	if is_colliding():
		var collider = get_collider()
		if collider is CharacterBody3D and collider.has_node("harm"):
			collider.harm -= damage
			collisions.append(collider)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_transform.origin,
		global_transform.origin + global_transform.basis.z * -100.0,
		0xFFFFFFFF,
		[self]
	)
	
	var results = space_state.intersect_ray(query)
	while !results.is_empty():
		var collider = results["collider"]
		if collider is CharacterBody3D and collider.has_node("harm"):
			collider.harm -= damage
		query.from = results["position"] + global_transform.basis.z * -0.1
		results = space_state.intersect_ray(query)
	
	queue_free()
