extends Node2D

func _ready():
	position = Vector2(0, 0)

func _physics_process(delta):
	for i in Net.players.keys():
		if i == Net.multiplayer.get_unique_id():
			continue
		if not has_node(String.num(i)):
			var new_op : Sprite2D = Sprite2D.new()
			new_op.texture = preload("res://Textures/placeholder_car.png")
			new_op.name = String.num(i)
			new_op.modulate = Color.DIM_GRAY
			add_child(new_op)
	for op in get_children():
		if not Net.players.has(int(String(op.name))):
			op.queue_free()
			continue
		if not Net.players[int(String(op.name))].has("car_data"):
			continue
		var car_data = Net.players[int(String(op.name))]["car_data"]
		op.rotation =  car_data["rotation"]
		op.position =  car_data["position"]
