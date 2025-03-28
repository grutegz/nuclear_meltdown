extends Node

# реализовал функционал открытия меню по вызову toggle_esc_menu. забиндил на backspace потому что на esc твой бинд уже стоит

var esc_menu = preload("res://scenes/esc_menu.tscn")
var esc_menu_instance = null 
var esc = true

var room_count = 6

var music_player = preload("res://scenes/things/music.tscn")
var music_player_instance = music_player.instantiate()

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
	
	# выставляем listener на сигнал close_requested с коллбэком на закрытие меню
	esc_menu_instance.connect("close_requested", close_esc_menu)
	
	get_tree().paused = true # паузим игру
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 

func close_esc_menu() -> void:
	if esc_menu_instance:
		esc_menu_instance.queue_free()
		esc_menu_instance = null
		
	var terminal = get_node("player/ui_terminal")
	if not terminal:
		get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
