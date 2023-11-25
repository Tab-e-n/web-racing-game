class_name RoadWidthChange
extends Line2D

@export var width_end = 512

func _ready():
	if not visible:
		queue_free()
	if points.size() > 2:
		queue_free()
	
	width_curve = Curve.new()
	width_curve.add_point(Vector2(0, 1))
	width_curve.add_point(Vector2(1, width_end / width))
	
	var a : float = points[1].x - points[0].x
	var b : float = points[1].y - points[0].y
	var point_distance : float = sqrt(a*a + b*b)
	var points_angle : float = incos(b/point_distance, a)
	
#	print(points_angle)
#	var angle = Sprite2D.new()
#	angle.texture = preload("res://Textures/debug_vector.png")
#	angle.offset.y = -32
#	angle.rotation = points_angle
#	add_child(angle)
	
	
	var poly = [points[0], points[0], points[1], points[1]]
	var flip = 1
	
	if points_angle >= PI:
		points_angle -= PI
		flip = -1
	
	var offset_start = width / 2 - 16
	var offset_end = width_end / 2 - 16
	poly[0].x += point_offset_sin(offset_start, points_angle) * flip
	poly[0].y += point_offset_cos(offset_start, points_angle) * flip
	
	poly[1].x -= point_offset_sin(offset_start, points_angle) * flip
	poly[1].y -= point_offset_cos(offset_start, points_angle) * flip
	
	poly[2].x -= point_offset_sin(offset_end, points_angle) * flip
	poly[2].y -= point_offset_cos(offset_end, points_angle) * flip
	
	poly[3].x += point_offset_sin(offset_end, points_angle) * flip
	poly[3].y += point_offset_cos(offset_end, points_angle) * flip
	
	
	var col = CollisionPolygon2D.new()
	col.polygon = poly
	print(poly)
	$Asphalt.add_child(col)
#	var pol = Polygon2D.new()
#	pol.polygon = poly
#	$Asphalt.add_child(pol)


func point_offset_cos(offset : float, angle : float):
	return offset * cos((PI / 2) - angle)


func point_offset_sin(offset : float, angle : float):
	return offset * sin((PI / 2) - angle)


func incos(n : float, x : float):
	var angle = acos(n)
	if x >= 0:
		angle = PI - angle
	if x < 0:
		angle += PI
	return angle
