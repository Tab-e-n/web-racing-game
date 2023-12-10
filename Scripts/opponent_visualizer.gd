extends Node2D


func _ready():
	position = Vector2(0, 0)


func _physics_process(_delta):
	manage_opponents()
	animate_opponents()


func manage_opponents():
	for i in Net.players.keys():
		if i == Net.multiplayer.get_unique_id():
			continue
		
		if Net.players[i]["car_data"].is_empty():
			continue
		
		if not has_node(String.num(i)):
			var new_op : Sprite2D = Sprite2D.new()
			new_op.texture = preload("res://Textures/placeholder_car_2.png")
			new_op.name = String.num(i)
			
			new_op.material = ShaderMaterial.new()
			new_op.material.shader = preload("res://Scripts/palette_replacer.gdshader")
			var palette = Palettes.PALETTES[Net.players[i]["palette"]].duplicate()
			new_op.material.set_shader_parameter("dim", Color.DARK_GRAY)
			new_op.material.set_shader_parameter("palette", palette)
			new_op.material.set_shader_parameter("active", true)
			
			add_child(new_op)
			
			var op_name : Label = Label.new()
			op_name.name = "name"
			op_name.text = Net.players[i]["name"]
			
			var stylebox : StyleBoxFlat = StyleBoxFlat.new()
			stylebox.bg_color = Color(0, 0, 0, 0.3)
			op_name.add_theme_stylebox_override("normal", stylebox)
#
#			op_name.pivot_offset = op_name.size / 2
#			op_name.position = -op_name.size / 2
			op_name.set_anchors_preset(Control.PRESET_TOP_LEFT)
			
			new_op.add_child(op_name)


func animate_opponents():
	for op in get_children():
		if not Net.players.has(int(String(op.name))):
			op.queue_free()
			continue
		
		if Net.players[int(String(op.name))]["car_data"].is_empty():
			op.queue_free()
			continue
		
		var car_data = Net.players[int(String(op.name))]["car_data"]
		op.rotation = car_data["rotation"]
		op.position = car_data["position"]
		if car_data["sliding"]:
			op.material.set_shader_parameter("dim", Color.DARK_GRAY * Color(0.5, 0.5, 0.5))
		else:
			op.material.set_shader_parameter("dim", Color.DARK_GRAY * Color(1, 1, 1))
		
		op.get_node("name").rotation = -op.rotation
