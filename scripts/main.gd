extends Node3D

var game_manager
var player
var camera_3d

func _ready():
	game_manager = $GameManager
	player = $Player
	camera_3d = $Camera3D
	
	# Setup game
	game_manager.init_game()
	player.init_player()

func _process(delta):
	if game_manager.state == game_manager.GameState.PLAYING:
		player.update_player(delta)
		update_camera()
		game_manager.update_game(delta)

func update_camera():
	# Follow player with offset
	var player_pos = player.position
	var camera_target = player_pos + Vector3(0, 5, 8)
	camera_3d.position = camera_3d.position.lerp(camera_target, 0.1)
