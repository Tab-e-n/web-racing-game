extends Line2D


func _ready():
	if not visible:
		return
	var line_poly = Geometry2D.offset_polyline(points, width / 2 - 4, Geometry2D.JOIN_MITER, Geometry2D.END_SQUARE)
	
	for poly in line_poly:
		var col = CollisionPolygon2D.new()
		col.polygon = poly
		$body.add_child(col)
#		var pol = Polygon2D.new()
#		pol.polygon = poly
#		$body.add_child(pol)

