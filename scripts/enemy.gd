extends Node3D

class_name Enemy

var speed = 8.0
var mesh_instance: MeshInstance3D

func init(start_pos: Vector3):
	position = start_pos
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(0.8, 1.0, 1.8)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0, 0)  # Neon red
	mesh_instance.set_surface_override_material(0, mat)
	
	add_child(mesh_instance)

func _process(delta):
	position.z += speed * delta
