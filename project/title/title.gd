extends Control

var COLORS : Array[Color] = [
	# Santo blue
	Color.html("8ed2e5"), 
	# Bright red
	Color.html("dc263b"),
	# Bright green
	Color.html("009f59"),
	# Bright yellow
	Color.html("cdca55"),
]

@export var main_game_scene : PackedScene

var _color_index := 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"start"):
		get_tree().change_scene_to_packed(main_game_scene)


func _on_color_flash_timer_timeout() -> void:
	_color_index = (_color_index + 1) % COLORS.size()
	%TitleLabel.label_settings.font_color = COLORS[_color_index]
