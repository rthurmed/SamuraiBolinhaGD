extends Area2D


onready var collision = $CollisionShape2D


func _ready():
	var _ok
	_ok = get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")


func _on_FlyingArea_body_exited(body):
	if body.is_in_group("cuttable"):
		body.queue_free()


func _on_Viewport_size_changed():
	collision.shape.extents = get_viewport_rect().size
