extends Node3D
var maseX = 0
var maseY = 0

const WALL = 1
const PATH = 0

var type = 0

const SOLDIER_PL = 0
const SOLDIER_SG = 1
const SENTRY_RG = 2

var soldier_pl = preload("res://scenes/soldier_pl.tscn")
var soldier_sg = preload("res://scenes/soldier_sg.tscn")
var sentry_rg = preload("res://scenes/sentry_rg.tscn")
var platform_scene = preload("res://scenes/things/grid_patform.tscn")
var cable_scene = preload("res://scenes/things/cable.tscn")

func _ready() -> void:
	var arr = generate_maze()
	var enemy_count = 0
	var sentry_count = 0
	var cable_count = 0
	var platforms_with_enemies = 0
	
	var platform_positions = []

	# Создаем платформы и собираем позиции для врагов/кабелей
	for i in range(maseX):
		for j in range(maseY):
			if arr[i][j] == PATH:
				var platform = platform_scene.instantiate()
				add_child(platform)
				var pos = Vector3(i*2+1, 0, j*2+1)
				platform.position = pos
				platform_positions.append(pos)

	# Перемешиваем список доступных платформ
	platform_positions.shuffle()

	# Расставляем кабели (макс. 4)
	for pos in platform_positions:
		if cable_count >= 4:
			break
		if randf() < 0.3:
			var cable = cable_scene.instantiate()
			add_child(cable)
			cable.position = pos + Vector3(0, 10, 0)
			cable_count += 1

	# Расставляем врагов (макс. 6)
	var enemies = []
	for pos in platform_positions:
		if platforms_with_enemies >= 6:
			break
		if randf() < 0.5:
			var enemy_type = get_random_enemy_type()
			if enemy_type == SENTRY_RG:
				if sentry_count < enemy_count / 3 or enemy_count == 0:
					var sentry = sentry_rg.instantiate()
					add_child(sentry)
					sentry.position = pos + Vector3(0, -1, 0)
					sentry.scale = Vector3(0.5, 0.5, 0.5)
					sentry.global_rotation = Vector3.ZERO
					sentry_count += 1
					enemy_count += 1
					platforms_with_enemies += 1
					enemies.append(sentry)
			else:
				var soldier
				if enemy_type == SOLDIER_PL:
					soldier = soldier_pl.instantiate()
				else:
					soldier = soldier_sg.instantiate()
				add_child(soldier)
				soldier.position = pos
				soldier.scale = Vector3(0.5, 0.5, 0.5)
				soldier.global_rotation = Vector3.ZERO
				enemy_count += 1
				platforms_with_enemies += 1
				enemies.append(soldier)

	if enemies.size() > 0:
		var random_enemy = enemies[randi() % enemies.size()]
		if random_enemy:random_enemy.sign=true

func get_random_enemy_type():
	match type:
		0:
			var options = [SOLDIER_PL, SENTRY_RG]
			return options[randi() % options.size()]
		1:
			var options = [SOLDIER_SG, SENTRY_RG]
			return options[randi() % options.size()]
		2:
			var options = [SOLDIER_PL, SOLDIER_SG]
			return options[randi() % options.size()]
		_:
			return randi() % 3

func generate_maze():
	maseX = int(maseX)
	maseY = int(maseY)
	var maze = []
	for i in range(maseX):
		maze.append([])
		for j in range(maseY):
			maze[i].append(WALL)

	var start_x = randi() % maseX
	var start_y = randi() % maseY
	maze[start_x][start_y] = PATH
	var cells = [Vector2(start_x, start_y)]

	while cells.size() > 0:
		var index = randi() % cells.size()
		var cell = cells[index]
		var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		directions.shuffle()

		var found = false
		for dir in directions:
			var new_x = cell.x + dir.x * 2
			var new_y = cell.y + dir.y * 2

			if new_x >= 0 and new_x < maseX and new_y >= 0 and new_y < maseY:
				if maze[new_x][new_y] == WALL:
					maze[new_x][new_y] = PATH
					maze[cell.x + dir.x][cell.y + dir.y] = PATH
					cells.append(Vector2(new_x, new_y))
					found = true
					break
		if not found:
			cells.pop_at(index)

	return maze
