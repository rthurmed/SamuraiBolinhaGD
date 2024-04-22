extends Area2D


func _on_KillArea_body_entered(body: CollisionObject2D):
	if not body.has_meta("flying"):
		body.set_meta("flying", true)
		return
	
	if body.get_meta("flying"):
		body.queue_free()
