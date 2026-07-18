extends Node3D

class_name Obstacle

var obstacle_type = "car"
var speed = 10.0
var mesh_instance: MeshInstance3D

func init(start_pos: Vector3, type: String):
	position = start_pos
	obstacle_type = type
	
	mesh_instance = MeshInstance3D.new()
	
	match type:
		"car":
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.mesh.size = Vector3(0.7, 0.7, 1.3)
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1.0, 0, 0)  # Neon red
			mat.emission = Color(0.5, 0, 0, 1.0)  # Red glow
			mesh_instance.set_surface_override_material(0, mat)
		
		"barrier":
			mesh_instance.mesh = BoxMesh.new()
			mesh_instance.mesh.size = Vector3(1.0, 0.6, 0.4)
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(1.0, 0.6, 0)  # Orange
			mat.emission = Color(0.5, 0.3, 0, 1.0)  # Orange glow
			mesh_instance.set_surface_override_material(0, mat)
		
		"oil":
			mesh_instance.mesh = CylinderMesh.new()
			mesh_instance.mesh.radius = 0.35
			mesh_instance.mesh.height = 0.2
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.2, 0.2, 0.2)  # Dark gray
			mesh_instance.set_surface_override_material(0, mat)
	
	add_child(mesh_instance)
