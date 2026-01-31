extends Node2D

@export var guy_scene : PackedScene

func _ready() -> void:
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
		_spawn_guy(index)
	)
	
