extends Node3D

class_name Player

var velocity = Vector3.ZERO
var speed = 0.0
var max_speed = 25.0
var acceleration = 5.0
var friction = 0.92
var boost_power = 0.0
var max_boost = 100.0
var health = 100.0
var max_health = 100.0

var car_body: MeshInstance3D
var car_collision: CollisionShape3D

func init_player():
	# Create car mesh
	car_body = MeshInstance3D.new()
	car_body.mesh = BoxMesh.new()
	car_body.mesh.size = Vector3(1.0, 1.0, 2.0)
	add_child(car_body)
	
	# Create collision shape
	car_collision = CollisionShape3D.new()
	car_collision.shape = BoxShape3D.new()
	car_collision.shape.size = Vector3(1.0, 1.0, 2.0)
	add_child(car_collision)
	
	# Material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1.0, 0.255)  # Neon green
	car_body.set_surface_override_material(0, material)

func update_player(delta: float):
	var input_vector = Vector3.ZERO
	
	# Input handling
	if Input.is_action_pressed("ui_right"):
		input_vector.x = 1.0
	if Input.is_action_pressed("ui_left"):
		input_vector.x = -1.0
	if Input.is_action_pressed("ui_up"):
		speed = min(speed + acceleration * delta, max_speed)
	if Input.is_action_pressed("ui_down"):
		speed = max(speed - acceleration * 1.5 * delta, 0)
	else:
		speed *= friction
	
	# Boost
	if Input.is_action_just_pressed("ui_space") and boost_power > 20:
		speed = min(speed + 10, max_speed * 1.5)
		boost_power -= 20
	
	# Regenerate boost
	boost_power = min(boost_power + 0.3 * delta, max_boost)
	
	# Update velocity
	velocity.x = input_vector.x * 8.0
	velocity.z = -speed
	
	# Move player
	position += velocity * delta
	
	# Keep in bounds (X axis)
	position.x = clamp(position.x, -4.5, 4.5)

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		health = 0

func get_health_percent() -> float:
	return health / max_health
