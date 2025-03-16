extends StaticBody3D

#GPT shizo posting, didnt work correctly

func create_wall(s: Vector3, pos: Vector3, axis: String):
	global_transform.origin = pos
	var cp1 = CollisionPolygon3D.new()
	var cp2 = CollisionPolygon3D.new()
	add_child(cp1)
	add_child(cp2)
	var p1
	var p2
	match axis:
		"x":
			p1 = [Vector3(0, -s.y/2, -s.z/2), Vector3(0, s.y/2, -s.z/2), Vector3(0, s.y/2, s.z/2), Vector3(0, -s.y/2, s.z/2)]
			p2 = [Vector3(0, -s.y/2, s.z/2), Vector3(0, s.y/2, s.z/2), Vector3(0, s.y/2, s.z * 1.5), Vector3(0, -s.y/2, s.z * 1.5)]
		"y":
			p1 = [Vector3(-s.x/2, 0, -s.z/2), Vector3(s.x/2, 0, -s.z/2), Vector3(s.x/2, 0, s.z/2), Vector3(-s.x/2, 0, s.z/2)]
			p2 = [Vector3(-s.x/2, 0, s.z/2), Vector3(s.x/2, 0, s.z/2), Vector3(s.x/2, 0, s.z * 1.5), Vector3(-s.x/2, 0, s.z * 1.5)]
		"z":
			p1 = [Vector3(-s.x/2, -s.y/2, 0), Vector3(s.x/2, -s.y/2, 0), Vector3(s.x/2, s.y/2, 0), Vector3(-s.x/2, s.y/2, 0)]
			p2 = [Vector3(-s.x/2, s.y/2, 0), Vector3(s.x/2, s.y/2, 0), Vector3(s.x/2, s.y*1.5, 0), Vector3(-s.x/2, s.y*1.5, 0)]
		_:
			push_error("build wall error: wrong direction")
			return
	cp1.polygon = PackedVector2Array(p1)
	cp2.polygon = PackedVector2Array(p2)


func _ready():
		create_wall(Vector3(5, 5, 5), Vector3(0, 0, 0), "x")
