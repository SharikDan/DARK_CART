extends Node3D

class_name Player

var velocity = Vector3.ZERO
var speed = 0.0
var max_speed = 30.0
var acceleration = 8.0
var friction = 0.91
var boost_power = 0.0
var max_boost = 100.0
var health = 100.0
var max_health = 100.0
var lateral_speed = 8.0

var car_body: MeshInstance3D
var car_collision: CollisionShape3D
var car_direction = 0  # -1, 0, 1

func init_player():
	# Create car mesh (green neon color)
	car_body = MeshInstance3D.new()
	car_body.mesh = BoxMesh.new()
	car_body.mesh.size = Vector3(0.8, 0.8, 1.5)
	add_child(car_body)
	
	# Create collision shape
	car_collision = CollisionShape3D.new()
	car_collision.shape = BoxShape3D.new()
	car_collision.shape.size = Vector3(0.8, 0.8, 1.5)
	add_child(car_collision)
	
	# Material - bright neon green
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 1.0, 0.255)  # Neon green
	material.emission = Color(0, 0.5, 0.127, 1.0)  # Glow effect
	car_body.set_surface_override_material(0, material)
	
	# Start position
	position = Vector3(0, 0.4, 0)

func update_player(delta: float):
	var input_vector = Vector3.ZERO
	
	# Input handling
	if Input.is_action_pressed("ui_right"):
		car_direction = 1
	if Input.is_action_pressed("ui_left"):
		car_direction = -1
	if !Input.is_action_pressed("ui_right") and !Input.is_action_pressed("ui_left"):
		car_direction = 0
	
	if Input.is_action_pressed("ui_up"):
		speed = min(speed + acceleration * delta, max_speed)
	if Input.is_action_pressed("ui_down"):
		speed = max(speed - acceleration * 1.5 * delta, 0)
	else:
		speed *= friction
	
	# Boost
	if Input.is_action_just_pressed("ui_space") and boost_power > 20:
		speed = min(speed + 8, max_speed * 1.4)
		boost_power -= 20
		print("⚡ BOOST! Speed: ", int(speed))
	
	# Regenerate boost
	boost_power = min(boost_power + 25 * delta, max_boost)
	
	# Update velocity
	velocity.x = car_direction * lateral_speed
	velocity.z = -speed
	
	# Move player
	position += velocity * delta
	
	# Keep in bounds (X axis)
	position.x = clamp(position.x, -4.5, 4.5)
	
	# Rotate car based on movement direction
	if car_direction != 0:
		car_body.rotation.y = lerp(car_body.rotation.y, car_direction * 0.3, 0.1)
	else:
		car_body.rotation.y = lerp(car_body.rotation.y, 0.0, 0.1)

func take_damage(damage: float):
	health -= damage
	if health <= 0:
		health = 0

func get_health_percent() -> float:
	return health / max_health

func get_boost_percent() -> float:
	return boost_power / max_boost
