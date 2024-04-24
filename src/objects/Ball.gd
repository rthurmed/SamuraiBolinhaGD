extends RigidBody2D
class_name Ball


onready var polygon = $Polygon2D
onready var collision = $CollisionPolygon2D

export var replace_polygon: PoolVector2Array = []
export var flying = false

var cutter: PoolVector2Array = []
var cutter_line: PoolVector2Array = []


func _ready():
	if len(replace_polygon) > 0:
		polygon.polygon = replace_polygon
		collision.polygon = replace_polygon
