extends Node2D

var MAX_PLAYERS := 2

@export var guy_scene : PackedScene

var _players : Array[Player]


func _ready() -> void:
	# Create the players
	for i in MAX_PLAYERS:
		var player := Player.new()
		_players.append(player)
	
	var spawn_points := %SpawnPoints.get_children()
	for i in spawn_points.size():
		_spawn_guy(i)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_fullscreen"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED else DisplayServer.WINDOW_MODE_WINDOWED)


func _spawn_guy(index:int) -> void:
	var guy : Guy = guy_scene.instantiate()
	guy.player_index = index
	guy.global_position = %SpawnPoints.get_children()[index].global_position
	add_child(guy)
	
	guy.died.connect(func():
		guy.queue_free()
		_players[index].lives -= 1
		if _players[index].lives > 0:
			_spawn_guy(index)
		
		_check_for_game_end()
	)
	
func _check_for_game_end() -> void:
	var someone_with_lives : Player = null
	for player in _players:
		if player.lives > 0:
			if someone_with_lives == null:
				# Someone has lives
				someone_with_lives = player
			else:
				# Two people have lives, the game is not over.
				return
	
	# If only one person has lives, they are the winner
	if someone_with_lives != null:
		_on_game_over(someone_with_lives)


func _on_game_over(winner:Player) -> void:
	var index = _players.find(winner)
	print("Winner is player %d" % index)
	
