extends CanvasLayer

func _ready():
	var main = get_parent()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_space"):
		var main = get_parent()
		if main.game_manager.state == main.game_manager.GameState.MENU:
			main.game_manager.start_game()
		elif main.game_manager.state == main.game_manager.GameState.GAME_OVER:
			get_tree().reload_current_scene()
