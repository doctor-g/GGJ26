extends Control

const MAX_PLAYERS := 4
const MAX_LIVES := 3

## How many seconds to wait before starting the next round
const TIME_BETWEEN_GAMES := 3.5
const BG_TWEEN_DURATION := 0.35

@export var guy_scene : PackedScene
@export var bg_color_1 : Color
@export var bg_color_2 : Color

var _players : Array[Player]

## When there is a winner, it is this player. If null, the game is ongoing.
var _winner : Player
## Manages the background color transition when someone wins
var _new_bg_color : Color

@onready var _background := $Background


func _ready() -> void:
	# Set the background to the default colors at the start of the game.
	_background.material.set_shader_parameter("color1", bg_color_1)
	_background.material.set_shader_parameter("color2", bg_color_2)
	
	# Create the players
	for i in MAX_PLAYERS:
		var player := Player.new()
		player.color = Palette.colors[i]
		player.lives = MAX_LIVES
		_players.append(player)
		
		var lives_control := preload("res://world/lives_control.tscn").instantiate()
		lives_control.player = player
		lives_control.number= i + 1
		%LivesBox.add_child(lives_control)
		
		_spawn_guy(i)


func _spawn_guy(index:int) -> void:
	var guy : Guy = guy_scene.instantiate()
	guy.player_index = index
	guy.color = _players[index].color
	guy.face_texture = Palette.faces[index]
	guy.global_position = %SpawnPoints.get_children()[index].global_position
	add_child(guy)
	
	guy.died.connect(func():
		%PlayerDiedSound.play()
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
	_winner = winner
	var bg_tween := create_tween()
	bg_tween.tween_method(_tween_background("color1"),
		bg_color_1, _winner.color, BG_TWEEN_DURATION)
	bg_tween.parallel().tween_method(_tween_background("color2"),
		bg_color_2, _winner.color.lightened(0.2), BG_TWEEN_DURATION)
	
	%WinSound.play()
	var index = _players.find(winner)
	%WinnerLabel.text = "Player %d Wins!" % (index+1)
	%WinnerLabel.visible = true
	for guy in get_tree().get_nodes_in_group(&"guys"):
		guy.active = false
	await get_tree().create_timer(TIME_BETWEEN_GAMES).timeout
	get_tree().reload_current_scene()


func _tween_background(parameter_name : String) -> Callable:
	return func(color:Color): _background.material.set_shader_parameter(parameter_name, color)
