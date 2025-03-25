extends Control

var type = 0
signal close_requested

func _ready() -> void:
	pass

func setup() -> void:
	pass

func _input(event) -> void:
	if Input.is_action_just_pressed("q"):
		emit_signal("close_requested")
		get_viewport().set_input_as_handled()
