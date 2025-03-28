extends Node

# реализовал функционал открытия меню по вызову toggle_esc_menu. забиндил на backspace потому что на esc твой бинд уже стоит

var esc_menu = preload("res://scenes/esc_menu.tscn")
var esc_menu_instance = null 
var esc = true

var room_count = 7

var music_player = preload("res://scenes/things/music.tscn")
var music_player_instance = music_player.instantiate()
var music_bus = AudioServer.get_bus_index("Music")

const VOLUME_CURVE = {
	"min_db": -40.0,
	"max_db": 0.0,
	"curve_exponent": 3.0 
}

func _ready() -> void:
	add_child(music_player_instance)
	music_player_instance.play()
	
	var prev_room = null
	for i in range(room_count):
		var room = preload("res://scenes/room.tscn").instantiate()
		if i==0: room.curShape=4
		else:
			
			room.curShape = randi() % 3 + 1
			room.curType = randi() % 4+1
		if prev_room:
			room.prevDoor = prev_room.nextDoor
			room.prevPos = prev_room.nextPos
		add_child(room)
		prev_room = room
	var room = preload("res://scenes/room.tscn").instantiate()
	if prev_room:
		room.prevDoor = prev_room.nextDoor
		room.prevPos = prev_room.nextPos
	room.curShape=5
	add_child(room)

func _linear_to_custom_volume(linear: float) -> float:
	var normalized = clamp(linear, 0.0, 1.0)
	print("Normalized: ", normalized)
	
	var curved = pow(normalized, 1.0/VOLUME_CURVE["curve_exponent"])
	print("Curved: ", curved)
	
	var db_range = VOLUME_CURVE["max_db"] - VOLUME_CURVE["min_db"]
	print("DB Range: ", db_range)
	
	var result = VOLUME_CURVE["min_db"] + curved * db_range
	print("Result: ", result)
	
	return result

func _input(event) -> void:
	if Input.is_action_just_pressed("esc"):
		print("ESC DETECTED")
		print(esc_menu_instance, "!!!")
	if Input.is_action_just_pressed("esc") and !esc_menu_instance:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if esc else Input.MOUSE_MODE_VISIBLE)
		open_esc_menu()

func open_esc_menu() -> void:
	# спавним сцену и даём ей право слушать нажатия клавиш
	esc_menu_instance = esc_menu.instantiate()
	esc_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(esc_menu_instance) 
	var terminal = get_node("player/ui_terminal")
	if not terminal:
		AudioServer.set_bus_volume_db(music_bus, -15.0) 
	
	# выставляем listener на сигнал close_requested с коллбэком на закрытие меню
	esc_menu_instance.connect("close_requested", close_esc_menu)
	
	get_tree().paused = true # паузим игру
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func close_esc_menu() -> void:
	if esc_menu_instance:
		esc_menu_instance.queue_free()
		esc_menu_instance = null
		
	if get_node("player").get_node("ui_terminal"):
		get_node("player").get_node("ui_terminal").set_process_input(true)
	
	var terminal = get_node("player/ui_terminal")
	if not terminal:
		get_tree().paused = false
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), _linear_to_custom_volume(Global.music_volume)) 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
