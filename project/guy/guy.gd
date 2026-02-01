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
const PUSH_EFFECT_DURATION := 0.5

@export var fireball_scene : PackedScene
@export var player_index := 0

var color : Color
var face_texture : Texture2D

## Set this to false to make this stop responding
var active := true

## If stunned, I am being pushed and cannot do anything.
var stunned := false

## How many fireballs does this guy have left.
var fireballs := 0:
	set(value):
		fireballs = value
		print("Did i do it")
		%HeadSprite.material.set_shader_parameter(&"enabled", fireballs > 0)

## If I am pushing, I cannot move left nor right
var _pushing := false

var _facing := Facing.RIGHT

# Cache these values so that the facing can be properly handled later.
@onready var _horizontal_push_center_x : float = %HorizontalPush.position.x
@onready var _jumping_push_center_x : float = %JumpingPush.position.x

@onready var _horizontal_push_sprite := $HorizontalPush/Visual
@onready var _jumping_push_sprite := $JumpingPush/Visual
@onready var _head_sprite := %HeadSprite
@onready var _body_sprite := %BodySprite


func _ready() -> void:
	_body_sprite.material.set_shader_parameter("replacement", color)
	%HeadSprite.texture = face_texture


func _physics_process(delta: float) -> void:
	if not active:
		return
	
	# Check for death
	if position.y >= KILL_Y:
		died.emit()
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		_body_sprite.play(&"jump")

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
			%JumpSound.play()
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
				%FireballStart.position.x *= -1
				_horizontal_push_sprite.flip_h = _facing == Facing.LEFT
				_jumping_push_sprite.flip_h = _facing == Facing.LEFT
				_body_sprite.flip_h = _facing == Facing.LEFT
				_head_sprite.flip_h = _facing == Facing.LEFT
		else:
			if is_on_floor():
				_body_sprite.play(&"idle")
			# Only slow down horizontal while on the ground.
			# This way, players who are pushed into the air complete their arc.
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, SPEED)

		# Handle attack action
		if Input.is_action_just_pressed("p%d_action" % player_index) and not _pushing:
			_pushing = true
			_body_sprite.play(&"push")
			
			if fireballs > 0:
				var fireball : Fireball = fireball_scene.instantiate()
				fireball.direction = Vector2.LEFT if _facing == Facing.LEFT else Vector2.RIGHT
				fireball.shooter = self
				fireball.global_position = %FireballStart.global_position
				add_sibling(fireball)
				fireballs -= 1
			else:
				
				# Adjust the position of the collision areas based on facing.
				%HorizontalPush.position.x = _horizontal_push_center_x * (-1 if _facing==Facing.LEFT else 1)
				%JumpingPush.position.x = _jumping_push_center_x * (-1 if _facing==Facing.LEFT else 1)
				
				# Show the correct push effect
				if is_on_floor():
					_horizontal_push_sprite.play()
					%HorizontalPush.visible = true
				else:
					_jumping_push_sprite.play()
					%JumpingPush.visible = true
				
				var area:Area2D = %HorizontalPush if is_on_floor() else %JumpingPush
				for body in area.get_overlapping_bodies():
					if body != self and body is Guy and is_instance_valid(body):
						_push(body)
			
			# Start the cooldown before the player can push again
			%PushCooldown.start()

	move_and_slide()


func _push(target:Guy) -> void:
	%HitSound.play()
	target.stunned = true
	if _facing==Facing.LEFT:
		target.velocity.x = -PUSH_STRENGTH
	else:
		target.velocity.x = PUSH_STRENGTH
	if not is_on_floor():
		target.velocity.y = PUSH_UPWARD_VELOCITY
	await get_tree().create_timer(PUSH_EFFECT_DURATION).timeout
	# If the target fell off the world, he won't be valid to un-stun.
	if is_instance_valid(target):
		target.stunned = false


func _on_push_cooldown_timeout() -> void:
	_pushing = false


func _on_visual_animation_finished() -> void:
	%HorizontalPush.visible = false
	%JumpingPush.visible = false


func kill() -> void:
	died.emit()
