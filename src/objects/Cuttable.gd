extends RigidBody2D
class_name Cuttable


onready var polygon = $Polygon2D
onready var collision = $CollisionPolygon2D

export var replace_polygon: PoolVector2Array = []
export var flying = false


func _ready():
	if len(replace_polygon) > 0:
		polygon.polygon = replace_polygon
		collision.polygon = replace_polygon
