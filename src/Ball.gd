extends RigidBody2D
class_name Ball


onready var polygon = $Polygon2D
onready var collision = $CollisionPolygon2D

var cutter: PoolVector2Array = []
var cutter_line: PoolVector2Array = []


func cut(from: Vector2, to: Vector2):
	# cuts the object into 2 other objects and destroys it
	collision.disabled = true
	cutter = PoolVector2Array([
		polygon.to_local(from),
		polygon.to_local(to),
		polygon.to_local(to + Vector2.ONE),
		polygon.to_local(from + Vector2.ONE),
	])
	
	var new_polygons = Geometry.clip_polygons_2d(polygon.polygon, cutter)
	for idx in range(len(new_polygons)):
		var data = new_polygons[idx]
		var node = Polygon2D.new()
		node.polygon = data
		node.texture = polygon.texture
		node.position = polygon.position
		node.modulate = Color(idx * 10, idx * 10, idx * 10)
		add_child(node)
		# TODO: create new objects


#func _draw():
#	if len(cutter) > 0:
#		var colors = PoolColorArray()
#		for _i in range(len(cutter)):
#			colors.append(Color.green)
#		draw_polygon(cutter, colors)
