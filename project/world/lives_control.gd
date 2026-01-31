extends Label

var number : int
var player : Player

func _ready() -> void:
	modulate = player.color
	
	_update_text()
	player.life_lost.connect(_update_text)
	

func _update_text() -> void:
	text = "Player %d: %d" % [number, player.lives]
