extends Control


var track : Node2D
var racecar : Racecar
var opponents : Node2D

@onready var gameplay : Gameplay = get_parent().get_parent()


func _ready():
	var track_loader = gameplay.get_node("track_loader")
	if track_loader == null:
		print("ERROR: Minimap can't find the track.")
		queue_free()
		return
	
	racecar = gameplay.get_node("Racecar")
	if racecar == null:
		print("ERROR: Minimap can't find the racecar.")
		queue_free()
		return
	
	opponents = gameplay.get_node("opponent_visualizer")
	if opponents == null:
		print("ERROR: Minimap can't find the opponent_visualizer.")
		queue_free()
		return
	
	
	track_loader.new_track_loaded.connect(_on_new_track_loaded)
	
	$player.position = size / Vector2(2, 2)


func _physics_process(_delta):
	$track.position = -racecar.position * $track.scale + size / Vector2(2, 2)
	$opponents.position = $track.position
	$player.rotation = racecar.rotation
	
	for op in opponents.get_children():
		if not $opponents.has_node(NodePath(op.name)):
			var new_op = Sprite2D.new()
			new_op.name = op.name
			new_op.texture = preload("res://Textures/ui/minimap_car.png")
			new_op.offset.y = -3
			new_op.self_modulate = Color.DARK_GRAY
			$opponents.add_child(new_op)
	for op in $opponents.get_children():
		if not opponents.has_node(NodePath(op.name)):
			op.queue_free()
			continue
		var linked_op = opponents.get_node(NodePath(op.name))
		op.position = linked_op.position * $track.scale
		op.rotation = linked_op.rotation


func _on_new_track_loaded(new_track : Node2D):
	track = new_track
	for i in $track.get_children():
		i.queue_free()
	for node in track.get_children():
		if node is Road or node is RoadWidthChange:
			var road = Line2D.new()
			road.rotation = node.rotation
			road.position = node.position
			road.scale = node.scale
			road.points = node.points.duplicate()
			road.width = node.width
			road.width_curve = node.width_curve
			$track.add_child(road)
		if node is Finish:
			var finish = Sprite2D.new()
			finish.texture = preload("res://Textures/finish.png") # CHANGE LATER
			finish.rotation = node.rotation
			finish.position = node.position
			finish.scale = node.scale
			finish.offset.y = 16
			finish.z_index = 1
			finish.region_enabled = true
			finish.region_rect.size = Vector2(node.width, 32)
			$track.add_child(finish)
