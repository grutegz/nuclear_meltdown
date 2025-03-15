extends Area3D

var speed = 50

func _process(delta: float) -> void:
	var movement = -transform.basis.z * speed * delta
	global_translate(movement)


func _on_body_entered(body: Node3D) -> void:
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	explosion.global_position=global_position
	get_parent().add_child(explosion)
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
