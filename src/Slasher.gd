extends Node2D

const BallScene = preload("res://src/Ball.tscn")

onready var raycast = $Raycast
onready var particles = $Particles


func _ready():
	set_active(false)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event
		position = mouse_event.position
		rotation = mouse_event.relative.angle()
		set_active(mouse_event.button_mask == 1)
	
	if event is InputEventScreenDrag:
		# TODO: test if gets touch screen inputs
		var drag_event: InputEventScreenDrag = event
		position = drag_event.position
		rotation = drag_event.relative.angle()


func _physics_process(_delta):
	if not raycast.is_colliding():
		return
	
	var ball: Ball = raycast.get_collider()
	cut(ball)


func set_active(value: bool):
	raycast.enabled = value
	particles.emitting = value


func cut(ball: Ball):
	# cuts the object into 2 other objects and destroys it
	var from = position + Vector2(-1000, 0).rotated(rotation)
	var to = position + Vector2(1000, 0).rotated(rotation)
	var normal = raycast.get_collision_normal()
	
	var cutter = PoolVector2Array([
		ball.polygon.to_local(from),
		ball.polygon.to_local(to),
		ball.polygon.to_local(to + Vector2.ONE),
		ball.polygon.to_local(from + Vector2.ONE),
	])
	
	ball.collision.disabled = true
	
	var new_polygons = Geometry.clip_polygons_2d(ball.polygon.polygon, cutter)
	
	for idx in range(len(new_polygons)):
		var points = new_polygons[idx]
		
		var pushing_force = 12
		var pushing_angle = normal.rotated(deg2rad(-90 + idx * 180))  # push 2 parts in opposite directions
		var pushing_velocity = pushing_angle * pushing_force
		
		var node = BallScene.instance()
		node.replace_polygon = points
		node.position = ball.position
		node.linear_velocity = ball.linear_velocity + pushing_velocity
		node.angular_velocity = ball.angular_velocity
		node.modulate = ball.modulate
		node.flying = true
		ball.get_parent().add_child(node)
	
	ball.queue_free()
