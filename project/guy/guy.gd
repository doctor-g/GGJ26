class_name Guy extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var player_number := 1

## If zero, I am not being pushed
var push_vector := Vector2.ZERO

var _facing := Facing.RIGHT

@onready var _horizontal_push_center_x : float = %HorizontalPush.position.x

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If not being pushed, the player has control of the character.
	if push_vector==Vector2.ZERO:
		# Handle jump.
		if Input.is_action_just_pressed("p%d_jump" % player_number) and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		var direction := Input.get_axis("p%d_left" % player_number, "p%d_right" % player_number)
		if direction:
			velocity.x = direction * SPEED
			# Face the direction of the input.
			# It has to be negative or positive here since we are inside the conditional.
			_facing = Facing.LEFT if direction < 0 else Facing.RIGHT
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

		%HorizontalPush.monitoring = Input.is_action_pressed("p%d_action" % player_number)
		%HorizontalPush.position.x = _horizontal_push_center_x * (-1 if _facing==Facing.LEFT else 1)
	else:
		velocity.x = push_vector.x * SPEED

	move_and_slide()


func _on_horizontal_push_body_entered(body: Node2D) -> void:
	if body is Guy:
		body.push_vector = Vector2.RIGHT
		await get_tree().create_timer(0.3).timeout
		body.push_vector = Vector2.ZERO


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("dead")
	queue_free()
