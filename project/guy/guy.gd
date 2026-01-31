class_name Guy extends CharacterBody2D

## Emitted when this guy falls off the edge of the world or otherwise dies.
signal died

enum Facing {LEFT, RIGHT}

const KILL_Y := 360 + 32 * 2 # Bottom of screen plus the height of the character
const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const PUSH_STRENGTH := 300.0
const PUSH_DECAY := 10.0
## How much upward velocity to add when pushing from the air.
const PUSH_UPWARD_VELOCITY := JUMP_VELOCITY / 2
## How long the push effect moves the target and removes its ability to control itself.
const PUSH_EFFECT_DURATION := 0.3

@export var player_index := 0

## If stunned, I am being pushed and cannot do anything.
var stunned := false

## If I am pushing, I cannot move left nor right
var _pushing := false

var _facing := Facing.RIGHT
var _is_push_ready := true

# Cache these values so that the facing can be properly handled later.
@onready var _horizontal_push_center_x : float = %HorizontalPush.position.x
@onready var _jumping_push_center_x : float = %JumpingPush.position.x

@onready var _horizontal_push_sprite := $HorizontalPush/Visual
@onready var _jumping_push_sprite := $JumpingPush/Visual
@onready var _body_sprite := %BodySprite


func _physics_process(delta: float) -> void:
	# Check for death
	if position.y >= KILL_Y:
		died.emit()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if stunned:
		_body_sprite.play(&"shoved_front")
		# No player controls while stunned.
		# Just reduce horizontal velocity by "friction" amount if on ground
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, PUSH_DECAY)
	
	elif _pushing:
		# Cannot move while pushing.
		# Just reduce horizontal velocity if on ground.
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# Regular locomotion.
	else:
		# Handle jump.
		if Input.is_action_just_pressed("p%d_jump" % player_index) and is_on_floor():
			_body_sprite.play(&"jump")
			velocity.y = JUMP_VELOCITY
			
		var direction := Input.get_axis("p%d_left" % player_index, "p%d_right" % player_index)
		if direction:
			if is_on_floor():
				_body_sprite.play(&"walk")
			velocity.x = direction * SPEED
			# Face the direction of the input.
			# It has to be negative or positive here since we are inside the conditional.
			var new_facing := Facing.LEFT if direction < 0 else Facing.RIGHT
			if new_facing != _facing:
				_facing = new_facing
				%HorizontalPush.position.x *= -1
				%JumpingPush.position.x *= -1
				%JumpingPush.rotation *= -1
				_horizontal_push_sprite.flip_h = _facing == Facing.LEFT
				_jumping_push_sprite.flip_h = _facing == Facing.LEFT
				_body_sprite.flip_h = _facing == Facing.LEFT
		else:
			if is_on_floor():
				_body_sprite.play(&"idle")
			# Only slow down horizontal while on the ground.
			# This way, players who are pushed into the air complete their arc.
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("p%d_action" % player_index) and _is_push_ready:
			_pushing = true
			_body_sprite.play(&"push")
			
			# Adjust the position of the collision areas based on facing.
			%HorizontalPush.position.x = _horizontal_push_center_x * (-1 if _facing==Facing.LEFT else 1)
			%JumpingPush.position.x = _jumping_push_center_x * (-1 if _facing==Facing.LEFT else 1)
			
			# Show the correct push effect
			%HorizontalPush.visible = is_on_floor()
			%JumpingPush.visible = not is_on_floor()
			
			var area:Area2D = %HorizontalPush if is_on_floor() else %JumpingPush
			for body in area.get_overlapping_bodies():
				if body != self and body is Guy and is_instance_valid(body):
					_push(body)
			
			# Hide the visual effect after a moment
			get_tree().create_timer(0.2).timeout.connect(func():
				%HorizontalPush.visible = false
				%JumpingPush.visible = false
			)
			
			# Start the cooldown before the player can push again
			_is_push_ready = false
			%PushCooldown.start()

	move_and_slide()


func _push(target:Guy) -> void:
	target.stunned = true
	if _facing==Facing.LEFT:
		target.velocity.x = -PUSH_STRENGTH
	else:
		target.velocity.x = PUSH_STRENGTH
	if not is_on_floor():
		target.velocity.y = PUSH_UPWARD_VELOCITY
	await get_tree().create_timer(PUSH_EFFECT_DURATION).timeout
	target.stunned = false


func _on_push_cooldown_timeout() -> void:
	_is_push_ready = true
	_pushing = false
