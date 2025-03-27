extends SubViewportContainer

@onready var gun = $SubViewport/cam/cur
@onready var player = get_parent().get_parent()
@onready var speed = player.velocity.length()

const guns = ["RL", "SG", "RG"]
var time_elapsed = 0.0

enum animation { idle, change, shoot }
var anim = animation.idle

var shoot_timer = 0.0
var shoot_duration = 0.1
var shoot_offset = Vector3(0, 0, 0)
var original_gun_position = Vector3.ZERO

var change_timer = 0.0
var change_duration = 0.25
var change_phase = 0 # 0 - опускание, 1 - смена, 2 - подъем
var next_gun_index = 0

func _ready() -> void:
	get_parent().get_parent().connect("updateModel", update_gun)
	original_gun_position = gun.position

func _process(delta):
	var window_size = get_window().size
	$SubViewport.size = Vector2(Global.resolution.x, Global.resolution.y)
	match anim:
		animation.idle:
			calc_offset(delta)
		animation.change:
			calc_change(delta)
		animation.shoot:
			calc_shoot(delta)
func calc_offset(delta):
	var rotation_speed_y = deg_to_rad(player.velocity.dot(player.transform.basis.x)) * delta * 7
	var rotation_speed_x = deg_to_rad(-player.velocity.dot(player.transform.basis.z)) * delta * 15
	var t = delta * 10
	gun.global_rotation.y += smoothstep(0.0, 1.0, t) * (rotation_speed_y - gun.global_rotation.y)
	gun.global_rotation.x += smoothstep(0.0, 1.0, t) * (rotation_speed_x - gun.global_rotation.x)
	speed = player.velocity.length()
	if speed > 0.1 and player.is_on_floor():
		time_elapsed += delta * speed
	var offsety = sin(time_elapsed) * 0.03
	var offsetx = cos(time_elapsed * 0.5) * 0.03
	gun.position = original_gun_position + Vector3(offsetx, offsety, 0)

func calc_shoot(delta):
	shoot_timer += delta
	var t = shoot_timer / shoot_duration
	if t < 0.5:
		shoot_offset.z = lerp(0.0, -0.2, t * 2)
	else:
		shoot_offset.z = lerp(-0.2, 0.0, (t - 0.5) * 2)
	gun.position = original_gun_position + shoot_offset
	if shoot_timer >= shoot_duration:
		shoot_timer = 0.0
		shoot_offset = Vector3.ZERO
		gun.position = original_gun_position
		anim = animation.idle

func calc_change(delta):
	change_timer += delta
	var t = change_timer / change_duration

	match change_phase:
		0:
			gun.position.y = lerp(original_gun_position.y, original_gun_position.y - 0.5, t)
			if t >= 1.0:
				change_phase = 1
				change_timer = 0.0
		1:
			update_gun(next_gun_index)
			change_phase = 2
			change_timer = 0.0
		2:
			gun.position.y = lerp(original_gun_position.y - 0.5, original_gun_position.y, t)
			if t >= 1.0:
				anim = animation.idle
				change_timer = 0.0
				change_phase = 0

func shoot():
	if anim != animation.idle:
		return
	anim = animation.shoot
	shoot_timer = 0.0

func change_gun(new_index: int):
	if anim != animation.idle:
		return
	anim = animation.change
	change_phase = 0
	change_timer = 0.0
	next_gun_index = new_index

func update_gun(n):
	$SubViewport/cam/cur/RG.visible = false
	$SubViewport/cam/cur/SG.visible = false
	$SubViewport/cam/cur/RL.visible = false
	$SubViewport/cam/cur.get_node(guns[n]).visible = true
