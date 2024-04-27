extends Area2D


func _on_FlyingArea_body_exited(body):
	if body.is_in_group("cuttable"):
		body.queue_free()
