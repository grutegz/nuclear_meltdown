extends Node3D
var maseX = 0
var maseY = 0

const WALL = 1
const PATH = 0

func _ready() -> void:
	var arr = generate_maze()
	for i in range(maseX):
		for j in range(maseY):
			if arr[i][j]:
				var platform = preload("res://scenes/things/grid_patform.tscn").instantiate()
				add_child(platform)
				platform.position=Vector3(i*2+1,0,j*2+1)
				if randi()%20==1:
					var cable = preload("res://scenes/things/cable.tscn").instantiate()
					add_child(cable)
					cable.position=Vector3(i*2+1,10,j*2+1)
				if randi()%30==1:
					var soldier = preload("res://scenes/soldier_sg.tscn").instantiate()
					add_child(soldier)
					soldier.position=Vector3(i*2+1,1,j*2+1)
					soldier.scale=Vector3(0.5,0.5,0.5)

func generate_maze():
	var maze = []
	
	for i in range(maseX):
		maze.append([])
		for j in range(maseY):
			maze[i].append(WALL)
	
	var start_x = randi() % maseX
	var start_y = randi() % maseY
	maze[start_x][start_y] = PATH
	var cells = []
	cells.append(Vector2(start_x, start_y))
	while cells.size() > 0:
		var index = randi() % cells.size()
		var cell = cells[index]
		var directions = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
		directions.shuffle()
		
		var found = false
		for dir in directions:
			var new_x = cell.x + dir.x * 2
			var new_y = cell.y + dir.y * 2
			
			if new_x >= 0 && new_x < maseX && new_y >= 0 && new_y < maseY:
				if maze[new_x][new_y] == WALL:
					maze[new_x][new_y] = PATH
					maze[cell.x + dir.x][cell.y + dir.y] = PATH
					cells.append(Vector2(new_x, new_y))
					found = true
					break
		if !found:
			cells.pop_at(index)
	
	return maze
