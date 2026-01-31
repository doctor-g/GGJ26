class_name Guy extends CharacterBody2D

enum Facing {LEFT, RIGHT}

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
## How long the push effect moves the target and removes its ability to control itself.
const PUSH_EFFECT_DURATION := 0.3

@export var player_index := 0

## If zero, I am not being pushed
var push_vector := Vector2.ZERO

var _facing := Facing.RIGHT

# Cache these values so that the facing can be properly handled later.
@onready var _horizontal_push_center_x : float = %HorizontalPush.position.x
@onready var _jumping_push_center_x : float = %JumpingPush.position.x

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# If not being pushed, the player has control of the character.
	if push_vector==Vector2.ZERO:
		# Handle jump.
		if Input.is_action_just_pressed("p%d_jump" % player_index) and is_on_floor():
			velocity.y = JUMP_VELOCITY
			
		var direction := Input.get_axis("p%d_left" % player_index, "p%d_right" % player_index)
		if direction:
			velocity.x = direction * SPEED
			# Face the direction of the input.
			# It has to be negative or positive here since we are inside the conditional.
			var new_facing := Facing.LEFT if direction < 0 else Facing.RIGHT
			if new_facing != _facing:
				_facing = new_facing
				%HorizontalPush.position.x *= -1
				%JumpingPush.position.x *= -1
				%JumpingPush.rotation *= -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		var is_pushing := Input.is_action_pressed("p%d_action" % player_index)
		if is_on_floor():
			%HorizontalPush.monitoring = is_pushing
			%JumpingPush.monitoring = false
		else:
			%HorizontalPush.monitoring = false
			%JumpingPush.monitoring = is_pushing
		
		# Adjust the position of the collision areas based on facing.
		%HorizontalPush.position.x = _horizontal_push_center_x * (-1 if _facing==Facing.LEFT else 1)
		%JumpingPush.position.x = _jumping_push_center_x * (-1 if _facing==Facing.LEFT else 1)
	else:
		velocity.x = push_vector.x * SPEED

	move_and_slide()


func _on_horizontal_push_body_entered(body: Node2D) -> void:
	if body is Guy and body != self and is_instance_valid(body):
		body.push_vector = Vector2.RIGHT if _facing==Facing.RIGHT else Vector2.LEFT
		await get_tree().create_timer(PUSH_EFFECT_DURATION).timeout
		body.push_vector = Vector2.ZERO


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("dead")
	queue_free()


func _on_jumping_push_body_entered(body: Node2D) -> void:
	if body is Guy and body != self and is_instance_valid(body):
		body.push_vector = Vector2.RIGHT if _facing==Facing.RIGHT else Vector2.LEFT
		body.velocity.y = JUMP_VELOCITY / 2 # Heuristic
		await get_tree().create_timer(PUSH_EFFECT_DURATION).timeout
		body.push_vector = Vector2.ZERO
