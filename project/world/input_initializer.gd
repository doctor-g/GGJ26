extends Node

@export var max_players := 4

func _ready() -> void:
	for i in max_players:
		var action_name := "p%d_left" % i
		InputMap.add_action(action_name)
		var left_event := InputEventJoypadMotion.new()
		left_event.axis = JOY_AXIS_LEFT_X
		left_event.axis_value = -1
		left_event.device = i
		InputMap.action_add_event(action_name, left_event)
		
		action_name = "p%d_right" % i
		InputMap.add_action(action_name)
		var right_event := InputEventJoypadMotion.new()
		right_event.axis = JOY_AXIS_LEFT_X
		right_event.axis_value = 1
		right_event.device = i
		InputMap.action_add_event(action_name, right_event)
		
		action_name = "p%d_jump" % i
		InputMap.add_action(action_name)
		var jump_event := InputEventJoypadButton.new()
		jump_event.button_index = JOY_BUTTON_A
		jump_event.device = i
		InputMap.action_add_event(action_name, jump_event)
		
		action_name = "p%d_action" % i
		InputMap.add_action(action_name)
		var action_event := InputEventJoypadButton.new()
		action_event.button_index = JOY_BUTTON_X
		action_event.device = i
		InputMap.action_add_event(action_name, action_event)
		
