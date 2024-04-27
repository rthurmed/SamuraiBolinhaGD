extends Area2D


const BallScene = preload("res://src/objects/Ball.tscn")
const WashingMachine = preload("res://src/objects/WashingMachine.tscn")
const Salmon = preload("res://src/objects/Salmon.tscn")
const Cucumber = preload("res://src/objects/Cucumber.tscn")
const Triangle = preload("res://src/objects/Triangle.tscn")
const Onion = preload("res://src/objects/Onion.tscn")
const Sardine = preload("res://src/objects/Sardine.tscn")

onready var collision = $CollisionShape2D

var scenes = [
	BallScene,
	WashingMachine,
	Salmon,
	Cucumber,
	Triangle,
	Onion,
	Sardine
]
var min_position = Vector2()
var max_position = Vector2()


func _ready():
	var shape: RectangleShape2D = collision.shape
	min_position = shape.extents / -2
	max_position = shape.extents / 2


func _on_Timer_timeout():
	var scene = scenes[floor(len(scenes) * randf())]
	var instance = scene.instance()
	
	instance.position.x = rand_range(min_position.x, max_position.x)
	instance.position.y = rand_range(min_position.y, max_position.y)
	instance.angular_velocity = rand_range(-10, 10)
	instance.linear_velocity.x = rand_range(-20, 20)
	instance.linear_velocity.y = -200
	
	add_child(instance)
