extends Node3D

class_name Enemy

var speed = 5.0
var mesh_instance: MeshInstance3D
var head: MeshInstance3D

func init(start_pos: Vector3):
	position = start_pos
	
	# Car body
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(0.7, 0.7, 1.3)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.2, 0)  # Dark red
	mat.emission = Color(0.5, 0.1, 0, 1.0)  # Dark red glow
	mesh_instance.set_surface_override_material(0, mat)
	
	add_child(mesh_instance)
	
	# Enemy indicator (glowing sphere on top)
	head = MeshInstance3D.new()	head.mesh = SphereMesh.new()
	head.mesh.radius = 0.2
	head.position.y = 0.6
	
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(1.0, 0.4, 0.4)
	head_mat.emission = Color(1.0, 0.2, 0.2, 1.0)
	head.set_surface_override_material(0, head_mat)
	
	add_child(head)
