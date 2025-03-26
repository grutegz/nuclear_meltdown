extends SubViewportContainer
@onready var gun = $SubViewport/cam/cur
@onready var player = get_parent().get_parent()
@onready var speed = player.velocity.length()

const guns = ["RL","SG","RG"]
var time_elapsed = 0.0
enum animation {idle, change, shoot}
var anim = 0

func _ready() -> void:
	get_parent().get_parent().connect("updateModel",update_gun)

func _process(delta):
	var window_size = get_window().size
	$SubViewport.size = Vector2(Global.resolution.x, Global.resolution.y)
	match anim:
		animation.idle:
			calc_offset(delta)
		animation.change:
			calc_change(delta)
	

func calc_offset(delta):
	var rotation_speed_y = deg_to_rad(player.velocity.dot(player.transform.basis.x)) * delta * 7
	var rotation_speed_x = deg_to_rad(-player.velocity.dot(player.transform.basis.z)) * delta * 15
	var t = delta * 10

	gun.global_rotation.y = gun.global_rotation.y + smoothstep(0.0, 1.0, t) * (rotation_speed_y - gun.global_rotation.y)
	gun.global_rotation.x = gun.global_rotation.x + smoothstep(0.0, 1.0, t) * (rotation_speed_x - gun.global_rotation.x)
	speed = player.velocity.length()
	if speed > 0.1 and player.is_on_floor():
		time_elapsed += delta * speed 
	var offsety = sin(time_elapsed) * 0.03
	var offsetx = cos(time_elapsed * 0.5) * 0.03
	gun.position.y = offsety
	gun.position.x = offsetx
func calc_change(delta):
	pass
func shoot(delta):
	pass
func update_gun(n):
	$SubViewport/cam/cur/RG.visible = false; $SubViewport/cam/cur/SG.visible = false; $SubViewport/cam/cur/RL.visible = false
	$SubViewport/cam/cur.get_node(guns[n]).visible=true
