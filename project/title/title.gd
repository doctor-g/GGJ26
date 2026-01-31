extends Control

@export var main_game_scene : PackedScene

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"start"):
		get_tree().change_scene_to_packed(main_game_scene)
