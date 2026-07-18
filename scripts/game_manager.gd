extends Node

class_name GameManager

enum GameState { MENU, PLAYING, GAME_OVER }

var state = GameState.MENU
var game_time = 90.0
var game_distance = 0.0
var game_score = 0
var time_elapsed = 0.0
var escape_success = false

var obstacles: Array = []
var enemies: Array = []
var spawn_timer = 0.0

func init_game():
	state = GameState.MENU


func start_game():
	state = GameState.PLAYING
	game_time = 90.0
	game_distance = 0.0
	game_score = 0
	time_elapsed = 0.0
	obstacles.clear()
	enemies.clear()

func update_game(delta: float):
	if state != GameState.PLAYING:
		return
	
	time_elapsed += delta
	game_time -= delta
	game_distance += 0.5  # Simulated distance
	
	# Spawn obstacles
	spawn_timer += delta
	if spawn_timer > 0.5:
		spawn_obstacle()
		spawn_timer = 0.0
	
	# Check game over
	if game_time <= 0:
		end_game(true)

func spawn_obstacle():
	var types = ["car", "barrier", "oil"]
	var random_type = types[randi() % types.size()]
	
	var pos_x = randf_range(-4, 4)
	var pos_y = 0.5
	var pos_z = -50.0
	
	var obstacle = preload("res://scripts/obstacle.gd").new()
	obstacle.init(Vector3(pos_x, pos_y, pos_z), random_type)
	obstacles.append(obstacle)

func end_game(success: bool):
	state = GameState.GAME_OVER
	escape_success = success
