extends Node2D

const MOVEMENT_DEADZONE = 2  # pixels per cycle
const MOVEMENT_MIN_SEGMENT_SIZE = 4
const MOVEMENT_MAX_SEGMENTS = 10
const CUT_RADIUS = 1

export var debug_line_path: NodePath
export var debug_line: bool

onready var raycast = $Raycast
onready var area = $Area2D
onready var particles = $Particles
onready var line: Line2D = get_node(debug_line_path) if debug_line_path else null

var cut_count = 0
var cursor_offset = Vector2.ZERO
var initial_viewport_rect = Rect2()
var last_pos = Vector2()
var segments = Array()
var reading = false
var was_reading = false


func _ready():
	var _ok
	_ok = get_viewport().connect("size_changed", self, "_on_Viewport_size_changed")
	initial_viewport_rect = get_viewport_rect()
	set_active(false)


func _unhandled_input(event):
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		var mouse_event: InputEventMouseMotion = event
		global_position = mouse_event.position + cursor_offset
		rotation = mouse_event.relative.angle()
		reading = mouse_event.button_mask == 1
		set_active(reading)


func _physics_process(delta: float):
	process_movement(delta)


func process_movement(_delta: float):
	var movement_delta = last_pos.distance_to(global_position)
	
	if reading and movement_delta > MOVEMENT_MIN_SEGMENT_SIZE:
		segments.push_front(global_position)
	
	if not reading and was_reading or not movement_delta > MOVEMENT_DEADZONE:
		segments = Array()
	
	if segments.size() > MOVEMENT_MAX_SEGMENTS:
		segments.pop_back()
	
	if debug_line:
		line.set_points(PoolVector2Array(segments))
	
	last_pos = global_position
	was_reading = reading


func _draw():
	pass


func set_active(value: bool):
	area.set_deferred("monitoring", value)
	particles.set_deferred("emitting", value)


func split_cuttable(cuttable: Cuttable, cutter: PoolVector2Array, normal: Vector2):
	var new_polygons = Geometry.clip_polygons_2d(cuttable.polygon.polygon, cutter)
	
	if len(new_polygons) <= 1:
		return
	
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
		cuttable.get_parent().call_deferred("add_child", node)
	
	cuttable.queue_free()


func cut_raycast(cuttable: Cuttable):
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
	
	split_cuttable(cuttable, cutter, normal)


func cut_area(cuttable: Cuttable):
	if !cuttable.polygon.is_inside_tree():
		return
	
	var normal = cuttable.position.direction_to(global_position)
	
	var offsets = Geometry.offset_polyline_2d(
		PoolVector2Array(segments),
		CUT_RADIUS,
		Geometry.JOIN_ROUND,
		Geometry.END_ROUND
	)
	var cutter_global = offsets[0]
	var cutter_local = PoolVector2Array()
	
	for point in cutter_global:
		cutter_local.append(cuttable.polygon.to_local(point))
	
	split_cuttable(cuttable, cutter_local, normal)


func _on_Viewport_size_changed():
	var size = initial_viewport_rect.size
	var viewport_diff = get_viewport_rect().size / size - Vector2.ONE
	var viewport_diff_px = viewport_diff * size
	cursor_offset = viewport_diff_px / 2 * -1


func _on_Area2D_body_entered(_body):
	pass


func _on_Area2D_body_exited(body):
	if body.is_in_group("cuttable"):
		var cuttable: Cuttable = body
		segments.push_front(global_position)
		cut_area(cuttable)
