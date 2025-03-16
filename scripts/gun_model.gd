extends SubViewportContainer
@onready var gun = $SubViewport/cam/cur
@onready var player = get_parent().get_parent()
@onready var speed = player.velocity.length()

var time_elapsed = 0.0

func _process(delta):
	var window_size = get_window().size
	$SubViewport.size = Vector2(window_size.x, window_size.y)
	gun.global_rotation.y = deg_to_rad(player.velocity.dot(player.transform.basis.x)) * delta * 5
	gun.global_rotation.x = deg_to_rad(-player.velocity.dot(player.transform.basis.z)) * delta * 5
	var speed = player.velocity.length()
	if speed > 0.1 and player.is_on_floor():
		time_elapsed += delta * speed 
	
	var offsety = sin(time_elapsed)* 0.01
	var offsetx = cos(time_elapsed * 0.5) * 0.01
	gun.position.y = offsety
	gun.position.x = offsetx
