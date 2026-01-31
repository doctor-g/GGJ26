extends Node2D


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body is Guy:
		body.queue_free()
		print("DEAD")
