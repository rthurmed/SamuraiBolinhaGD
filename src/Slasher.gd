extends Node2D


onready var raycast = $Raycast
onready var particles = $Particles


func _ready():
	set_active(false)


func _unhandled_input(event):
	# FIXME: only active when clicking
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event
		position = mouse_event.position
		raycast.rotation = mouse_event.relative.angle()
		set_active(mouse_event.button_mask == 1)
	
	if event is InputEventScreenDrag:
		# TODO: test if gets touch screen inputs
		var drag_event: InputEventScreenDrag = event
		position = drag_event.position
		raycast.rotation = drag_event.relative.angle()


func _physics_process(_delta):
	if not raycast.is_colliding():
		return
	
	var ball: Node2D = raycast.get_collider()
	ball.queue_free()


func set_active(value: bool):
	raycast.enabled = value
	particles.emitting = value
