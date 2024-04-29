extends RigidBody2D
class_name Cuttable


onready var polygon = $Polygon2D
onready var collision = $CollisionPolygon2D

export var replace_polygon: PoolVector2Array = []
export var flying = false


func _ready():
	add_to_group("cuttable")
	if len(replace_polygon) > 0:
		polygon.set_deferred("polygon", replace_polygon)
		collision.set_deferred("polygon", replace_polygon)
