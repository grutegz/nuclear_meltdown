extends Control

var type = 4
const texts = ["res://assets/texts/tutor.txt", "res://assets/texts/last.txt", "res://assets/texts/welcome.txt"]
var text = 0
var code = randi()%9000+1000
signal close2_requested

# режим1
var typing_speed = 0.03
var lines = []
var cur_line = 0
var typing = false
var player_locked = false
var illustration_texture : Texture
var term_node=null
var watch

@onready var illustration = $ColorRect/illustration
@onready var output = $ColorRect/screen
@onready var input = $ColorRect/inp/inp
func _ready() -> void:
	setup()
	if type == 1:
		load_lines(texts[text])

func setup() -> void:
	match type:
		1:
			input.visible = false
			output.visible = true
			illustration.visible = true
			output.text = ""
			if !lines.is_empty():
				start_typing()
		2:
			output.text="Добро пожаловать в 1.4*10**7 блок управления энергией! Для отключения питания введите код:"
			illustration.texture = load("res://assets/pictures/key.png")
			input.text=""
		3:
			output.text="H E L L O   T H E R E \n you can configure some settings of the lab! \n type 1 for high emissions \n (gravity and time will decrease)"
			illustration.texture = load("res://assets/pictures/settings.png")
		_:
			output.text="Печенье удачи говорит: "+fortunes[randi()%len(fortunes)]
			illustration.texture = load("res://assets/pictures/cookie.png")

func load_lines(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	while not file.eof_reached():
		var line = file.get_line()
		if line.strip_edges() != "":
			lines.append(line)
	file.close()

func start_typing() -> void:
	if cur_line >= lines.size():
		queue_free()
		emit_signal("close2_requested")
		return
	
	var line = lines[cur_line]
	
	if line.begins_with("#"):
		handle_image_command(line)
		return 
	
	typing = true
	output.text = ""
	
	for char in line:
		if !typing:
			break
		output.text += char
		await get_tree().create_timer(typing_speed).timeout
	
	typing = false
	cur_line += 1

func handle_image_command(line: String) -> void:
	var parts = line.split(" ")
	if parts.size() < 2:
		push_error("Invalid image command: " + line)
		return
	
	var texture_path = "res://assets/pictures/" + parts[1]
	
	if not FileAccess.file_exists(texture_path):
		push_error("Image not found: ", texture_path)
		return
	
	var texture = load(texture_path)
	if not texture:
		push_error("Failed to load texture: ", texture_path)
		return
	
	illustration.texture = texture
	cur_line += 1

	await get_tree().create_timer(0.1).timeout
	start_typing()

var currentCode = ""
func _input(event) -> void:
	var main = get_parent().get_parent() #!!!!! если сцену вызовет не player программа ляжет моментально
	if Input.is_action_just_pressed("esc") and !get_parent().get_parent().esc_menu_instance:
		main.open_esc_menu()
	if Input.is_key_pressed(KEY_Q):
		emit_signal("close2_requested")
		get_viewport().set_input_as_handled()
	match type:
		2:
			if event is InputEventKey:
				if Input.is_key_pressed(KEY_0): currentCode+="0"
				elif Input.is_key_pressed(KEY_1): currentCode+="1"
				elif Input.is_key_pressed(KEY_2): currentCode+="2"
				elif Input.is_key_pressed(KEY_3): currentCode+="3"
				elif Input.is_key_pressed(KEY_4): currentCode+="4"
				elif Input.is_key_pressed(KEY_5): currentCode+="5"
				elif Input.is_key_pressed(KEY_6): currentCode+="6"
				elif Input.is_key_pressed(KEY_7): currentCode+="7"
				elif Input.is_key_pressed(KEY_8): currentCode+="8"
				elif Input.is_key_pressed(KEY_9): currentCode+="9"
				if Input.is_key_pressed(KEY_BACKSPACE):currentCode=currentCode.substr(0,len(currentCode)-1)
				input.text=currentCode

			if event.is_action_pressed("ui_accept"):
				if currentCode==str(get_parent().code):
					if term_node: term_node.get_parent().get_node("Area3D").monitoring=true
					get_parent().code = randi()%9000+1000
					get_parent().get_node("UI/sign").visible = false
					get_tree().paused = false
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					emit_signal("close2_requested")
					queue_free()
					get_viewport().set_input_as_handled()
					watch.update_time()
					watch.start()
				else:
					output.text="НЕВЕРНО! введите еще раз:"
					currentCode=""
				
		1:
			if event.is_action_pressed("ui_accept"):
				if typing:
					typing = false
					output.text = lines[cur_line]
				else:
					#cur_line += 1
					start_typing()
		3: if Input.is_key_pressed(KEY_1): pass

var fortunes = [
		"Вас ждет приятный сюрприз.",
		"Хорошие вещи приходят в маленьких упаковках. Будьте внимательны!",
		"Ваш усердный труд скоро окупится.",
		"Приключения ждут вас за следующим поворотом.",
		"Примите неизвестность, она таит в себе захватывающие возможности.",
		"Прислушивайтесь к своей интуиции; она знает путь.",
		"Не бойтесь рискнуть чем-то новым.",
		"Путешествие в тысячу миль начинается с одного шага.",
		"Вы найдете счастье в неожиданных местах.",
		"Ваша креативность расцветет в ближайшие дни.",
		"Терпение – это добродетель, особенно сейчас.",
		"Протянутая рука помощи появится, когда она вам больше всего понадобится.",
		"Верьте в себя, и другие тоже поверят.",
		"Хорошие новости придут к вам по почте (или электронной почте!).",
		"Лучшие вещи в жизни бесплатны (и иногда их можно найти в печенье).",
		"Учитесь на своем прошлом, но не зацикливайтесь на нем.",
		"Вы сильнее, чем думаете.",
		"Делитесь своими талантами с миром.",
		"Новая дружба принесет радость в вашу жизнь.",
		"Успех – это путешествие, а не пункт назначения.",
		"ваш ip 127.0.0.1 >:)",
]
