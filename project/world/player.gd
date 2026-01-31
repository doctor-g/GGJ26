class_name Player extends RefCounted

signal life_lost

var lives : int:
	set(value):
		var old_lives := lives
		lives = value
		if lives < old_lives:
			life_lost.emit()
		
var color : Color
