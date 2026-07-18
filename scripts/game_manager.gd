extends Node3D

class_name GameManager

enum GameState { MENU, PLAYING, GAME_OVER }

var state = GameState.MENU
var game_time = 90.0
var game_distance = 0.0
var game_score = 0
var time_elapsed = 0.0
var escape_success = false

var main_scene
var player
var obstacles: Array = []
var enemies: Array = []
var spawn_timer = 0.0
var enemy_spawn_timer = 0.0

func init_game(main: Node3D):
	main_scene = main
	player = main_scene.player
	state = GameState.MENU


func start_game():
	state = GameState.PLAYING
	game_time = 90.0
	game_distance = 0.0
	game_score = 0
	time_elapsed = 0.0
	obstacles.clear()
	enemies.clear()
	spawn_timer = 0.0
	enemy_spawn_timer = 0.0
	print("\n🎮 GAME STARTED!")

func update_game(delta: float):
	if state != GameState.PLAYING:
		return
	
	time_elapsed += delta
	game_time -= delta
	game_distance += player.speed * delta
	game_score += int(player.speed) + len(enemies) * 5
	
	# Spawn obstacles
	spawn_timer += delta
	if spawn_timer > 0.4:
		spawn_obstacle()
		spawn_timer = 0.0
	
	# Spawn enemies
	enemy_spawn_timer += delta
	if enemy_spawn_timer > 1.0 and len(enemies) < 3:
		spawn_enemy()
		enemy_spawn_timer = 0.0
	
	# Update obstacles
	for obstacle in obstacles:
		obstacle.position.z += 15.0 * delta
		
		# Check collision
		if obstacle.position.distance_to(player.position) < 1.5:
			if obstacle.obstacle_type == "oil":
				player.speed *= 0.6
			else:
				player.take_damage(20)
				print("COLLISION! Health: ", player.health)
		
		# Remove if too far
		if obstacle.position.z > 20:
			obstacle.queue_free()
			obstacles.erase(obstacle)
	
	# Update enemies
	for enemy in enemies:
		# Simple AI - move towards player
		var dir_to_player = (player.position - enemy.position).normalized()
		enemy.position += dir_to_player * enemy.speed * delta
		enemy.position.z += 8.0 * delta
		
		# Check collision with player
		if enemy.position.distance_to(player.position) < 1.2:
			player.take_damage(30)
			print("ENEMY HIT! Health: ", player.health)
		
		# Remove if too far
		if enemy.position.z > 20:
			enemy.queue_free()
			enemies.erase(enemy)
	
	# Check game over conditions
	if game_time <= 0:
		end_game(true)
		print("✅ ESCAPED! Time's up!")
	elif player.health <= 0:
		end_game(false)
		print("❌ CAUGHT! Health depleted!")
	
	# Print stats every 10 seconds
	if int(time_elapsed) % 10 == 0 and int(time_elapsed * 10) % 100 == 0:
		print("Time: ", int(game_time), "s | Distance: ", int(game_distance), "m | Score: ", game_score)

func spawn_obstacle():
	var types = ["car", "barrier", "oil"]
	var random_type = types[randi() % types.size()]
	
	var pos_x = randf_range(-3.5, 3.5)
	var pos_y = 0.5
	var pos_z = -30.0
	
	var obstacle = main_scene.spawn_obstacle(Vector3(pos_x, pos_y, pos_z), random_type)
	obstacles.append(obstacle)

func spawn_enemy():
	var pos_x = randf_range(-3.5, 3.5)
	var pos_y = 0.5
	var pos_z = -35.0
	
	var enemy = main_scene.spawn_enemy(Vector3(pos_x, pos_y, pos_z))
	enemies.append(enemy)

func end_game(success: bool):
	state = GameState.GAME_OVER
	escape_success = success
	print("\n=== GAME OVER ===")
	print("Time Survived: ", int(time_elapsed), "s")
	print("Distance Covered: ", int(game_distance), "m")
	print("Final Score: ", game_score)
