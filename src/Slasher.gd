extends Node2D

const BallScene = preload("res://src/objects/Ball.tscn")

onready var raycast = $Raycast
onready var particles = $Particles

var cut_count = 0
var cursor_offset = Vector2.ZERO
var initial_viewport_rect = Rect2()


func _ready():
	var _ok
	_ok = get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")
	initial_viewport_rect = get_viewport_rect()
	set_active(false)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event
		global_position = mouse_event.position + cursor_offset
		rotation = mouse_event.relative.angle()
		set_active(mouse_event.button_mask == 1)
	
	if event is InputEventScreenDrag:
		# TODO: test if gets touch screen inputs
		var drag_event: InputEventScreenDrag = event
		global_position = drag_event.position + cursor_offset
		rotation = drag_event.relative.angle()


func _physics_process(_delta):
	if not raycast.is_colliding():
		return
	
	var cuttable: Cuttable = raycast.get_collider()
	cut(cuttable)
	cut_count = cut_count + 1
	# print(cut_count)


func set_active(value: bool):
	raycast.enabled = value
	particles.emitting = value


func cut(cuttable: Cuttable):
	# cuts the object into 2 other objects and destroys it
	var from = position + Vector2(-1000, 0).rotated(rotation)
	var to = position + Vector2(1000, 0).rotated(rotation)
	var normal = raycast.get_collision_normal()
	
	var cutter = PoolVector2Array([
		cuttable.polygon.to_local(from),
		cuttable.polygon.to_local(to),
		cuttable.polygon.to_local(to + Vector2.ONE),
		cuttable.polygon.to_local(from + Vector2.ONE),
	])
	
	var new_polygons = Geometry.clip_polygons_2d(cuttable.polygon.polygon, cutter)
	
	for idx in range(len(new_polygons)):
		var points = new_polygons[idx]
		
		var pushing_force = 12
		var pushing_angle = normal.rotated(deg2rad(-90 + idx * 180))  # push 2 parts in opposite directions
		
		var pushing_velocity = pushing_angle * pushing_force
		
		var node = cuttable.duplicate()
		node.replace_polygon = points
		node.position = cuttable.position
		node.linear_velocity = cuttable.linear_velocity + pushing_velocity
		node.angular_velocity = cuttable.angular_velocity
		node.modulate = cuttable.modulate
		node.flying = true
		cuttable.get_parent().add_child(node)
	
	cuttable.queue_free()


func _on_Viewport_size_changed():
	var size = initial_viewport_rect.size
	var viewport_diff = get_viewport_rect().size / size - Vector2.ONE
	var viewport_diff_px = viewport_diff * size
	cursor_offset = viewport_diff_px / 2 * -1
