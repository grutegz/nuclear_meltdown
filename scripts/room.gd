extends StaticBody3D

@onready var door = preload("res://scenes/things/door1.tscn").instantiate()

func _ready():
	create_door_wall(Vector2(40, 40), Vector3(0, 0, 0), Vector3.BACK, "bricks1", Vector2(20,4))
	create_wall(Vector2(40, 40), Vector3(0, 0, 20), Vector3.FORWARD, "bricks1")
	create_wall(Vector2(40, 40), Vector3(20, 0, 0), Vector3.LEFT, "bricks1")
	create_wall(Vector2(40, 40), Vector3(0, 0, 0), Vector3.RIGHT, "bricks1")
	create_wall(Vector2(40, 40), Vector3(0, 0, 0), Vector3.UP, "floor1")
	create_wall(Vector2(40, 40), Vector3(0, 20, 0), Vector3.DOWN, "floor1")

func create_door_wall(sz: Vector2, ps: Vector3, dir: Vector3, texture: String, dps:Vector2):
	var door_ps = get_size_3d(dps, dir)
	var door_sized_ps = door_ps
	print(door_ps)
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
