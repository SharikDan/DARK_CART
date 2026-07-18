extends Node3D

var game_manager
var player
var camera_3d
var ui_layer
var road_mesh
var obstacles_container
var enemies_container

func _ready():
	game_manager = $GameManager
	player = $Player
	camera_3d = $Camera3D
	ui_layer = $UI
	
	# Create containers for obstacles and enemies
	obstacles_container = Node3D.new()
	obstacles_container.name = "Obstacles"
	add_child(obstacles_container)
	
	enemies_container = Node3D.new()
	enemies_container.name = "Enemies"
	add_child(enemies_container)
	
	# Create road
	create_road()
	
	# Setup game
	game_manager.init_game(self)
	player.init_player()
	
	# Show menu
	show_menu()

func create_road():
	var road = MeshInstance3D.new()
	var road_mesh_data = PlaneMesh.new()
	road_mesh_data.size = Vector2(10, 200)
	road.mesh = road_mesh_data
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.2)  # Dark road
	road.set_surface_override_material(0, mat)
	
	road.position.z = -50
	add_child(road)

func _process(delta):
	if game_manager.state == game_manager.GameState.PLAYING:
		player.update_player(delta)
		update_camera()
		game_manager.update_game(delta)
		update_ui()

func update_camera():
	var player_pos = player.position
	var camera_target = player_pos + Vector3(0, 4, 6)
	camera_3d.position = camera_3d.position.lerp(camera_target, 0.08)
	
	var look_at_target = player_pos + Vector3(0, 1, -5)
	camera_3d.look_at(look_at_target, Vector3.UP)

func update_ui():
	pass

func show_menu():
	print("=== DARK CART - 3D ===")
	print("Press SPACE to start game")
	
func show_game_over():
	print("\nGAME OVER")
	if game_manager.escape_success:
		print("MISSION COMPLETE!")
	else:
		print("MISSION FAILED!")
	print("Final Score: ", game_manager.game_score)

func spawn_obstacle(pos: Vector3, type: String):
	var obstacle = load("res://scripts/obstacle.gd").new()
	obstacle.init(pos, type)
	obstacles_container.add_child(obstacle)
	return obstacle

func spawn_enemy(pos: Vector3):
	var enemy = load("res://scripts/enemy.gd").new()
	enemy.init(pos)
	enemies_container.add_child(enemy)
	return enemy
