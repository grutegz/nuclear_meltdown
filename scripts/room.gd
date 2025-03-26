extends StaticBody3D

enum shape {I,Z,L,O,s}
enum type { ROOM1,ROOM2,ROOM3,LAB,ERR,OFFICE }
var curType = 0

var cellS :int = 40
var wallS :int = 30

var prevDoor = Vector2()
var prevPos =  Vector3()
var nextDoor = Vector2(2,0)
var nextPos = Vector3()

func _ready():
	create_room(prevPos,"1floor","1floor",curType,0)
func create_door_wall(sz: Vector2, ps: Vector3, dir: Vector3, texture: String, dps:Vector2, d):
	var door_ps = get_size_3d(dps, dir)
	var door_sized_ps = door_ps
	match dir:
		Vector3.DOWN, Vector3.UP,Vector3.RIGHT, Vector3.LEFT: return
		Vector3.FORWARD, Vector3.BACK: door_sized_ps+=Vector3(4, 4, 0)

	create_wall(Vector2(dps.x,dps.y+4),ps,dir,texture)
	create_wall(Vector2(sz.x-dps.x,dps.y),ps+door_ps/2-Vector3(0,door_ps.y,0)/2,dir,texture)
	create_wall(Vector2(dps.x+4,sz.y-dps.y-4),ps+Vector3(0,door_sized_ps.y,0)/2,dir,texture)
	create_wall(Vector2(sz.x-dps.x-4,sz.y),ps+door_sized_ps/2-Vector3.UP*2,dir,texture)
	if d:
		var door = preload("res://scenes/things/door1.tscn").instantiate()
		add_child(door)
		door.position = door_ps+ps*2
		if curType!=4:
			var fan = preload("res://scenes/things/fan.tscn").instantiate()
			fan.position=Vector3(door_ps.x+2,0,door_ps.z-8)+ps*2
			add_child(fan)


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

enum Pattern {CHECKERBOARD, NOISE, STRIPPED}

func create_texture(tex1: String, tex2: String, sz: Vector2, ps: Vector3, pattern: Pattern = Pattern.CHECKERBOARD) -> ImageTexture:
	var image1 = load("res://assets/textures/" + tex1 + ".png").get_image()
	var image2 = load("res://assets/textures/" + tex2 + ".png").get_image()
	image1.convert(Image.FORMAT_RGBA8)
	image2.convert(Image.FORMAT_RGBA8)
	
	var texture_size = Vector2i(int(ceil(sz.x)) * 16, int(ceil(sz.y)) * 16)
	var new_image = Image.create(texture_size.x, texture_size.y, false, Image.FORMAT_RGBA8)
	
	var tile_size = 32
	var tiles_x = texture_size.x / tile_size
	var tiles_y = texture_size.y / tile_size

	var img1_size = image1.get_size()
	var img2_size = image2.get_size()

	var adjusted_ps = Vector2(
		clamp(ps.x, 0, min(img1_size.x, img2_size.x) - tile_size),
		clamp(ps.y, 0, min(img1_size.y, img2_size.y) - tile_size))
	
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = 1
	noise.fractal_octaves = 3
	noise.frequency = 0.07
	
	for ty in tiles_y:
		for tx in tiles_x:
			var use_first: bool
			
			match pattern:
				Pattern.CHECKERBOARD:
					use_first = (tx + ty) % 2 == 0
				Pattern.NOISE:
					var noise_value = noise.get_noise_2d(tx+ ps.z, ty+ps.z)
					use_first = noise_value <0.1
					
				Pattern.STRIPPED:
					use_first = tx % 2 == 0
				_:
					use_first = (tx + ty) % 2 == 0
			
			var source_image = image1 if use_first else image2
			var dst_pos = Vector2i(tx * tile_size, ty * tile_size)
			new_image.blit_rect(source_image, Rect2i(adjusted_ps.x, adjusted_ps.y, tile_size, tile_size), dst_pos)
	
	return ImageTexture.create_from_image(new_image)
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
	if texture[0]=="0":
		var test_texture = create_texture(texture.substr(1)+"1", texture.substr(1)+"2", sz, ps,0)
		material.albedo_texture = test_texture
		material.uv1_scale = Vector3(1, 1, 1)
	elif texture[0]=="1":
		var test_texture = create_texture(texture.substr(1)+"1", texture.substr(1)+"2", sz, ps,1)
		material.albedo_texture = test_texture
		material.uv1_scale = Vector3(1, 1, 1)
	else:
		var texture_path = "res://assets/textures/" + texture + ".png"
		material.albedo_texture = load(texture_path)
		material.uv1_scale = Vector3(sz.x*0.5, sz.y*0.5, 0)
	material.texture_filter = material.TEXTURE_FILTER_NEAREST
	
	mesh_inst.mesh = wall_mesh
	mesh_inst.material_override = material
	mesh_inst.position = ps
	
	return mesh_inst
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
func create_room(ps, floor, wall, shp, tp):
	
	match shp:
		shape.I:
			nextDoor = get_random_door_position(Vector2(cellS, wallS))
			#exit
			nextPos=Vector3(ps.x, ps.y, ps.z + cellS * 2)
			create_door_wall(Vector2(cellS, wallS), nextPos, Vector3.FORWARD, wall,nextDoor,true)
			#enter
			create_door_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall,prevDoor,false)
			create_wall(Vector2(cellS * 4, wallS), Vector3(ps.x + cellS / 2.0, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS * 4, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, cellS * 4), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS, cellS * 4), Vector3(ps.x, ps.y + wallS / 2.0, ps.z), Vector3.DOWN, floor)
			room_platforms(shp)
		shape.Z:
			nextDoor = get_random_door_position(Vector2(cellS, wallS))
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z + cellS), Vector3.FORWARD, wall)
			#enter
			create_door_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall, prevDoor, false)
			create_wall(Vector2(cellS * 2, wallS), Vector3(ps.x + cellS / 2.0, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, cellS * 2), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS, cellS * 2), Vector3(ps.x, ps.y + wallS / 2.0, ps.z), Vector3.DOWN, floor)
			
			create_wall(Vector2(cellS, wallS), Vector3(ps.x - cellS / 2.0, ps.y, ps.z + cellS / 2.0), Vector3.BACK, wall)
			create_wall(Vector2(cellS * 2, wallS), Vector3(ps.x - cellS / 2.0, ps.y, ps.z + cellS / 2.0), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z + cellS), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, cellS * 2), Vector3(ps.x - cellS / 2.0, ps.y + wallS / 2.0, ps.z + cellS / 2.0), Vector3.DOWN, floor)
			create_wall(Vector2(cellS, cellS * 2), Vector3(ps.x - cellS / 2.0, ps.y, ps.z + cellS / 2.0), Vector3.UP, floor)
			#exit
			nextPos=Vector3(ps.x - cellS / 2.0, ps.y, ps.z + cellS * 1.5)
			create_door_wall(Vector2(cellS, wallS), nextPos, Vector3.FORWARD, wall, nextDoor,true)
			room_platforms(shp)
		shape.L:
			nextDoor = get_random_door_position(Vector2(cellS, wallS))
			create_wall(Vector2(cellS, cellS * 3), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			#enter
			create_door_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall,prevDoor,false)
			create_wall(Vector2(cellS * 2, wallS), Vector3(ps.x + cellS / 2.0, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS * 3, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			
			create_wall(Vector2(cellS, wallS), Vector3(ps.x, ps.y, ps.z + cellS * 1.5), Vector3.FORWARD, wall)
			#exit
			nextPos= Vector3(ps.x+cellS*0.5, ps.y, ps.z + cellS * 1.5)
			create_door_wall(Vector2(cellS, wallS), nextPos, Vector3.FORWARD, wall,nextDoor,true)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x + cellS / 2.0, ps.y, ps.z + cellS), Vector3.BACK, wall)
			create_wall(Vector2(cellS, cellS), Vector3(ps.x + cellS / 2.0, ps.y, ps.z + cellS), Vector3.UP, floor)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x + cellS, ps.y, ps.z + cellS), Vector3.LEFT, wall)
			create_wall(Vector2(cellS, cellS * 3), Vector3(ps.x, ps.y + wallS / 2.0, ps.z), Vector3.DOWN, floor)
			create_wall(Vector2(cellS, cellS), Vector3(ps.x + cellS / 2.0, ps.y + wallS / 2.0, ps.z + cellS), Vector3.DOWN, floor)
			room_platforms(shp)
		shape.O:
			nextDoor = get_random_door_position(Vector2(cellS, wallS))
			#exit
			nextPos=Vector3(ps.x, ps.y, ps.z + cellS)
			create_door_wall(Vector2(cellS, wallS), nextPos, Vector3.FORWARD, wall,nextDoor,true)
			create_wall(Vector2(cellS, wallS), Vector3(ps.x+cellS*0.5, ps.y, ps.z + cellS), Vector3.FORWARD, wall)
			#enter
			create_door_wall(Vector2(cellS * 2, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall,prevDoor,false)
			create_wall(Vector2(cellS * 2, wallS), Vector3(ps.x + cellS, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(cellS * 2, wallS), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(cellS * 2, cellS * 2), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(cellS * 2, cellS * 2), Vector3(ps.x, ps.y + wallS / 2.0, ps.z), Vector3.DOWN, floor)
			room_platforms(shp)
		shape.s:
			nextPos=Vector3(ps.x, ps.y, ps.z + 4)
			create_door_wall(Vector2(8, 8), Vector3(ps.x, ps.y, ps.z + 4), Vector3.FORWARD, wall, Vector2(2,0),true)
			create_wall(Vector2(8, 8), Vector3(ps.x, ps.y, ps.z), Vector3.BACK, wall)
			create_wall(Vector2(8, 8), Vector3(ps.x + 4, ps.y, ps.z), Vector3.LEFT, wall)
			create_wall(Vector2(8, 8), Vector3(ps.x, ps.y, ps.z), Vector3.RIGHT, wall)
			create_wall(Vector2(8, 8), Vector3(ps.x, ps.y, ps.z), Vector3.UP, floor)
			create_wall(Vector2(8, 8), Vector3(ps.x, ps.y + 4, ps.z), Vector3.DOWN, floor)
func room_platforms(shp):
	match shp:
		shape.I:
			var platform1 = preload("res://scenes/things/platforms.tscn").instantiate()
			var platform2 = preload("res://scenes/things/platforms.tscn").instantiate()
			platform1.maseX=cellS/4.0-4
			platform1.maseY=cellS/2.0
			platform2.maseX=cellS/4.0-4
			platform2.maseY=cellS/2.0
			add_child(platform1)
			add_child(platform2)
			platform1.position=Vector3(cellS/4.0,10,cellS/2.0)+ prevPos*2
			platform1.scale=Vector3(2,2,2)
			platform2.position=Vector3(cellS/4.0,20,cellS*1.5)+ prevPos*2
			platform2.scale=Vector3(2,2,2)
		shape.Z:
			var platform1 = preload("res://scenes/things/platforms.tscn").instantiate()
			var platform2 = preload("res://scenes/things/platforms.tscn").instantiate()
			platform1.maseX=cellS/4.0-4
			platform1.maseY=cellS/3.0
			platform2.maseX=cellS/4.0-4
			platform2.maseY=cellS/3.0
			add_child(platform1)
			add_child(platform2)
			platform1.position=Vector3(0,10,cellS/2.0)+ prevPos*2
			platform1.scale=Vector3(2,2,2)
			platform2.position=Vector3(-cellS/2.0-4,20,cellS+8)+ prevPos*2
			platform2.scale=Vector3(2,2,2)
		shape.L:
			var platform1 = preload("res://scenes/things/platforms.tscn").instantiate()
			var platform2 = preload("res://scenes/things/platforms.tscn").instantiate()
			platform1.maseX=cellS/4.0-4
			platform1.maseY=cellS/2.0
			platform2.maseX=cellS/2.0-4
			platform2.maseY=cellS/4.0-4
			add_child(platform1)
			add_child(platform2)
			platform1.position=Vector3(cellS/4.0,10,cellS/2.0)+ prevPos*2
			platform1.scale=Vector3(2,2,2)
			platform2.position=Vector3(cellS/4.0,20,cellS*1.5+20)+ prevPos*2
			platform2.scale=Vector3(2,2,2)
		shape.O:
			var platform1 = preload("res://scenes/things/platforms.tscn").instantiate()
			var platform2 = preload("res://scenes/things/platforms.tscn").instantiate()
			platform1.maseX=cellS/3.0
			platform1.maseY=cellS/3.0
			platform2.maseX=cellS/3.0
			platform2.maseY=cellS/3.0
			add_child(platform1)
			add_child(platform2)
			platform1.position=Vector3(0,10,cellS/2.0)+ prevPos*2
			platform1.scale=Vector3(2,2,2)
			platform2.position=Vector3(cellS-12,20,cellS/2.0)+ prevPos*2
			platform2.scale=Vector3(2,2,2)
func get_random_door_position(wall_size: Vector2) -> Vector2:
	var door_x = randi()*2%int(wall_size.x-8)+4
	var door_y = randi()*2%int(wall_size.y-8)+4
	return Vector2(door_x, door_y)
