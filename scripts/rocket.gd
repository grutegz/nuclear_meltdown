extends Area3D

var speed = 50
var player=false

func _process(delta: float) -> void:
	var movement = -transform.basis.z * speed * delta
	global_translate(movement)


func _on_body_entered(body: Node3D) -> void:
	if body.has_node("player") and player:return
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	if player:explosion.player=true
	explosion.global_position=global_position
	queue_free()


func _on_timer_timeout() -> void:
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	
	explosion.global_position=global_position
	queue_free()
