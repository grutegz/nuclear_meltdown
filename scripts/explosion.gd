extends Area3D

var streight = 60
func _ready() -> void:
	$aud.play()
func _on_timer_timeout() -> void:
	queue_free()
func _process(delta: float) -> void:
	streight/=exp(delta*0.9)

func _on_body_entered(body: Node3D) -> void:
	if body.has_node("mov"):
		if body.has_node("player"):body.vel.append((body.position-position).normalized()*(1/(body.position-position).length())*streight)
		else:print((body.position-position).normalized()*(1/(body.position-position).length())*streight*10)
	if body.has_node("harm"):
		if body.has_node("player"):body.harm -= streight*0.05
		else: body.harm -= streight*0.2
