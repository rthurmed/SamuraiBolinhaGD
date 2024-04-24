extends Area2D


func _on_KillArea_body_entered(body: CollisionObject2D):
	if not body.is_in_group("ball"):
		return
	
	var ball: Cuttable = body
	if ball.flying:
		ball.queue_free()
	else:
		ball.flying = true
