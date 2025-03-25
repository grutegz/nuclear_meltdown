@tool
extends Control

var type = 2
var code = randi()%9000+1000
signal close_requested

@onready var output = $ColorRect/screen
@onready var input = $ColorRect/inp/inp


#
func _ready() -> void:
	setup()

func setup() -> void:
	match type:
		1:
			pass
		2:
			output.text="enter code:"
			input.text=""
		3:
			output.text="cookie says: "+fortunes[randi()%len(fortunes)]
		_:
			output.text="i use arch btw"
			
var currentCode = ""
func _input(event) -> void:
	if Input.is_key_pressed(KEY_Q):
		emit_signal("close_requested")
		get_viewport().set_input_as_handled()
		process_input()
		
func process_input() -> void:
	match type:
		2:
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

var fortunes = [
	"A pleasant surprise is waiting for you.",
	"Good things come in small packages.  Keep an eye out!",
	"Your hard work will soon pay off.",
	"Adventure awaits you around the next corner.",
	"Embrace the unknown, it holds exciting possibilities.",
	"Listen to your intuition; it knows the way.",
	"Don't be afraid to take a chance on something new.",
	"A journey of a thousand miles begins with a single step.",
	"You will find happiness in unexpected places.",
	"Your creativity will blossom in the coming days.",
	"Patience is a virtue, especially now.",
	"A helping hand will appear when you need it most.",
	"Believe in yourself, and others will too.",
	"Good news will come to you by mail (or email!).",
	"The best things in life are free (and sometimes found in cookies).",
	"Learn from your past, but don't dwell on it.",
	"You are stronger than you think.",
	"Share your talents with the world.",
	"A new friendship will bring joy to your life." ,
	"Success is a journey, not a destination.",
	"your ip is 127.0.0.1 >:)",
]
