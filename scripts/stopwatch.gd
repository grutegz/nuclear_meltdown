extends Control

var time_remaining: float = 60.0
var initial_time: float = 0.0
var is_running: bool = false
const MIN_TIME: float = 60.0
const MAX_TIME: float = 75.0
const COEFFICIENT: float = 0.5
func _ready() -> void:
	$timer.wait_time = 0.1
	update_display(0.0)

func set_initial_time(seconds: float) -> void:
	initial_time = seconds
	time_remaining = seconds
	update_display(time_remaining)

func start() -> void:
	if time_remaining > 0:
		is_running = true
		$timer.start()

func stop() -> void:
	is_running = false
	$timer.stop()

func reset() -> void:
	time_remaining = initial_time
	update_display(time_remaining)

func _on_timer_timeout() -> void:
	if is_running:
		time_remaining -= $timer.wait_time
		update_display(time_remaining)
		
		if time_remaining <= 0:
			time_remaining = 0
			stop()
			on_timer_zero()

func update_display(time: float) -> void:
	var minutes = int(time / 60)
	var seconds = fmod(time, 60)
	$time_label.text = "%02d:%02d" % [minutes, int(seconds)]

func update_time() -> void:
	if time_remaining < MIN_TIME:
		time_remaining = MIN_TIME
	else:
		var additional_time = time_remaining * COEFFICIENT
		time_remaining = min(time_remaining + additional_time, MAX_TIME)
	
	update_display(time_remaining)

func on_timer_zero() -> void:
	print("Таймер достиг нуля!")
	# Здесь можно добавить любые действия, которые должны произойти при достижении нуля
