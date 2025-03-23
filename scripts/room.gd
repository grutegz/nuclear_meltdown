extends StaticBody3D

@onready var door = preload("res://scenes/things/door1.tscn").instantiate()

enum shape {I,Z,L,O}
var cellS :int = 40
var wallS :int = 20


func _ready():
	create_room(Vector3(0,0,0),"floor2","bricks1",1)
	#var maze = generate_maze(MAZE_SIZE)
	#print_maze(maze)
func create_door_wall(sz: Vector2, ps: Vector3, dir: Vector3, texture: String, dps:Vector2):
	var door_ps = get_size_3d(dps, dir)
	var door_sized_ps = door_ps
	match dir:
		Vector3.DOWN, Vector3.UP: return
		Vector3.FORWARD, Vector3.BACK: door_sized_ps+=Vector3(4, 4, 0)
		Vector3.RIGHT, Vector3.LEFT: door_sized_ps+=Vector3(4, 4, 0)
	create_wall(Vector2(dps.x,dps.y+4),ps,dir,texture)
	create_wall(Vector2(sz.x-dps.x,dps.y),ps+door_ps/2-Vector3(0,door_ps.y,0)/2,dir,texture)
	create_wall(Vector2(dps.x+4,sz.y-dps.y-4),ps+Vector3(0,door_sized_ps.y,0)/2,dir,texture)
	create_wall(Vector2(sz.x-dps.x-4,sz.y),ps+door_sized_ps/2-Vector3(0,door_sized_ps.y,0)/2,dir,texture)
	add_child(door)
	door.position = door_ps + dir*0.1


func create_wall(sz: Vector2, ps: Vector3, dir: Vector3, texture: String):
	if sz==Vector2.ZERO:return
	var sz3d = get_size_3d(sz, dir)
	var verts = get_wall_verts(sz3d, ps, dir)
	
	var col_shape = create_collision_shape(verts, ps)
	var mesh_inst = create_mesh_instance(verts, sz, dir, texture, ps)
	
	add_child(col_shape)
	add_child(mesh_inst)

func get_size_3d(sz: Vector2, dir: Vector3) -> Vector3:
	match dir:
		Vector3.DOWN, Vector3.UP: return Vector3(sz.x, 0, sz.y)
		Vector3.FORWARD, Vector3.BACK: return Vector3(sz.x, sz.y, 0)
		Vector3.RIGHT, Vector3.LEFT: return Vector3(0, sz.y, sz.x)
		_:
			push_error("Invalid direction")
			return Vector3.ZERO

func get_wall_verts(sz3d: Vector3, ps: Vector3, dir: Vector3) -> Array:
	var p0 = ps
	var p1 = ps + Vector3(sz3d.x, 0, 0)
	var p2 = ps + Vector3(0, 0, sz3d.z)
	var p3 = ps + Vector3(sz3d.x, 0, sz3d.z)
	var p4 = ps + Vector3(0, sz3d.y, 0)
	var p5 = ps + Vector3(sz3d.x, sz3d.y, 0)
	var p6 = ps + Vector3(0, sz3d.y, sz3d.z)

	match dir:
		Vector3.DOWN:  return [p0, p2, p3, p0, p3, p1]
		Vector3.UP:    return [p1, p3, p2, p1, p2, p0]
		Vector3.FORWARD: return [p0, p1, p5, p0, p5, p4]
		Vector3.BACK:  return [p4, p5, p1, p4, p1, p0]
		Vector3.RIGHT: return [p0, p2, p6, p0, p6, p4]
		Vector3.LEFT:  return [p4, p6, p2, p4, p2, p0]
		_:
			push_error("Invalid direction")
			return []

func create_collision_shape(verts: Array, ps: Vector3) -> CollisionShape3D:
	var col_shape = CollisionShape3D.new()
	var col = ConcavePolygonShape3D.new()
	col.set_faces(PackedVector3Array(verts))
	col_shape.shape = col
	col_shape.position = ps
	return col_shape

func create_mesh_instance(verts: Array, sz: Vector2, dir: Vector3, texture: String, ps: Vector3) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	var surf_tool = SurfaceTool.new()
	
	surf_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var uvs = get_uvs(dir)
	
	for i in range(6):
		surf_tool.set_uv(uvs[i])
		surf_tool.add_vertex(verts[i])
	
	surf_tool.generate_normals()
	var wall_mesh = surf_tool.commit()
	
	var material = StandardMaterial3D.new()
	var texture_path = "res://assets/textures/" + texture + ".png"
	
	
	material.albedo_texture = load(texture_path)
	material.uv1_scale = Vector3(sz.x*0.5, sz.y*0.5, 0)
	material.texture_filter = material.TEXTURE_FILTER_NEAREST
	
	mesh_inst.mesh = wall_mesh
	mesh_inst.material_override = material
	mesh_inst.position = ps
	
	return mesh_inst
func create_texture(tex1,tex2,sz:Vector2,ps:Vector3):
	#var noise = FastNoiseLite.new()
	
	var mergedTexture 
	return mergedTexture

func get_uvs(dir: Vector3) -> Array:
	match dir:
		Vector3.UP, Vector3.DOWN:
			return [
				Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),
				Vector2(1, 0), Vector2(0, 1), Vector2(0, 0)
			]
		Vector3.LEFT, Vector3.RIGHT:
			return [
				Vector2(0, 0), Vector2(1, 0), Vector2(1, 1),
				Vector2(0, 0), Vector2(1, 1), Vector2(0, 1)
			]
		Vector3.FORWARD, Vector3.BACK:
			return [
				Vector2(0, 1), Vector2(1, 1), Vector2(1, 0),
				Vector2(0, 1), Vector2(1, 0), Vector2(0, 0)
			]
		_:
			push_error("Invalid direction")
			return []
func create_room(ps,floor, wall, shp):
	match shp:
		shape.I:
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y,ps.z+cellS*2), Vector3.FORWARD, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall)
			create_wall(Vector2(cellS*4, wallS), Vector3(ps.x+cellS/2, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS*4, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, cellS*4), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS, cellS*4), Vector3(ps.x, ps.y+wallS/2, ps.z), Vector3.DOWN, floor)
		shape.Z:
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y,ps.z+cellS), Vector3.FORWARD, wall)
			#enter
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x+cellS/2, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, cellS*2), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS, cellS*2), Vector3(ps.x, ps.y+wallS/2, ps.z), Vector3.DOWN, floor)
			
			create_wall(Vector2(cellS, wallS), Vector3(ps.x-cellS/2, ps.y, ps.z+cellS/2), Vector3.BACK, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x-cellS/2, ps.y, ps.z+cellS/2), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z+cellS), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, cellS*2), Vector3(ps.x-cellS/2, ps.y+wallS/2, ps.z+cellS/2), Vector3.DOWN, floor)
			create_wall(Vector2(cellS, cellS*2), Vector3(ps.x-cellS/2, ps.y, ps.z+cellS/2), Vector3.UP, floor)
			#exit
			create_wall(Vector2(cellS, wallS), Vector3(ps.z-cellS/2, ps.y,ps.z+cellS*1.5), Vector3.FORWARD, wall)
		shape.L:
			create_wall(Vector2(cellS, cellS*3), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			#enter
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x+cellS/2, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS*3, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			#exit
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x, ps.y,ps.z+cellS*1.5), Vector3.FORWARD, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x+cellS/2, ps.y, ps.z+cellS), Vector3.BACK, wall)
			create_wall(Vector2(cellS, cellS), Vector3(ps.x+cellS/2, ps.y, ps.z+cellS), Vector3.UP, floor)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x+cellS, ps.y, ps.z+cellS), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, cellS*3), Vector3(ps.x, ps.y+wallS/2, ps.z), Vector3.DOWN, floor)
			create_wall(Vector2(cellS, cellS), Vector3(ps.x+cellS/2, ps.y+wallS/2, ps.z+cellS), Vector3.DOWN, floor)
		shape.O:
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x, ps.y,ps.z+cellS), Vector3.FORWARD, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x+cellS, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS*2, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS*2, cellS*2), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS*2, cellS*2), Vector3(ps.x, ps.y+wallS/2, ps.z), Vector3.DOWN, floor)

# АЛГОРИТМЫ

var MAZE_SIZE = 20

const WALL = 1
const PATH = 0

func generate_maze(size):
	var maze = []
	
	for i in range(size):
		maze.append([])
		for j in range(size):
			maze[i].append(WALL)
	
	var start_x = randi() % size
	var start_y = randi() % size
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
			
			if new_x >= 0 && new_x < size && new_y >= 0 && new_y < size:
				if maze[new_x][new_y] == WALL:
					maze[new_x][new_y] = PATH
					maze[cell.x + dir.x][cell.y + dir.y] = PATH
					cells.append(Vector2(new_x, new_y))
					found = true
					break
		if !found:
			cells.pop_at(index)
	
	return maze
func print_maze(maze):
	for row in maze:
		var line = ""
		for cell in row:
			if cell == WALL:
				line += "#"
			else:
				line += " "
		print(line)	
