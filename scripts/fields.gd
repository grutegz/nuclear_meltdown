@tool
extends StaticBody3D

@export var cell_size: float = 10.0
@export var grid_size: int = 100
@export var height_scale: float = 10.0

var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.1
	generate_mesh()

func generate_mesh():
	var st = SurfaceTool.new()
	var mesh = ArrayMesh.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var vertices = []
	var indices = []

	for z in range(grid_size + 1):
		for x in range(grid_size + 1):
			var world_x = x * cell_size
			var world_z = z * cell_size
			var height = noise.get_noise_2d(world_x, world_z) * height_scale
			vertices.append(Vector3(world_x, height, world_z))

	for z in range(grid_size):
		for x in range(grid_size):
			var i = x + z * (grid_size + 1)
			var i_right = i + 1
			var i_bottom = i + (grid_size + 1)
			var i_bottom_right = i_bottom + 1
			
			indices.append(i_right)
			indices.append(i_bottom)
			indices.append(i_bottom_right)
			
			indices.append(i)
			indices.append(i_bottom)
			indices.append(i_right)


	for v in vertices:
		st.add_vertex(v)

	for i in range(0, indices.size(), 3):
		st.add_index(indices[i])
		st.add_index(indices[i + 1])
		st.add_index(indices[i + 2])
	st.generate_normals()
	st.commit(mesh)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	add_child(mesh_instance)
	var collision_shape = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(indices.map(func(i): return vertices[i]))
	collision_shape.shape = shape
	add_child(collision_shape)
