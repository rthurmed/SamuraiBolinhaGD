extends Area2D


const Ball = preload("res://src/Ball.tscn")
const COLORS = [
	Color("#e14141"),
	Color("#83e04c"),
	Color("#fff275"),
	Color("#6eeeff"),
	Color("#ff80aa"),
	Color("#39855a"),
]

onready var collision = $CollisionShape2D

var min_position = Vector2()
var max_position = Vector2()


func _ready():
	var shape: RectangleShape2D = collision.shape
	min_position = shape.extents / -2
	max_position = shape.extents / 2


func _on_Timer_timeout():
	var instance = Ball.instance()
	instance.position.x = rand_range(min_position.x, max_position.x)
	instance.position.y = rand_range(min_position.y, max_position.y)
	instance.angular_velocity = rand_range(-10, 10)
	instance.linear_velocity.x = rand_range(-20, 20)
	instance.linear_velocity.y = -200
	instance.modulate = COLORS[rand_range(0, len(COLORS))]
	add_child(instance)
