class_name Fireball extends Area2D

const SPEED := 7.5

var shooter : Guy
var direction := Vector2.RIGHT

func _ready() -> void:
	if direction == Vector2.LEFT:
		$AnimatedSprite2D.flip_h = true


func _physics_process(_delta: float) -> void:
	position += direction * SPEED


func _on_body_entered(body: Node2D) -> void:
	if body != shooter and body is Guy:
		queue_free()
		body.kill()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
