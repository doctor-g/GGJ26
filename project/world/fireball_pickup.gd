extends Area2D

const FIREBALLS_GAINED := 3

func _on_body_entered(body: Node2D) -> void:
	if body is Guy:
		body.fireballs += FIREBALLS_GAINED
		queue_free()
