@tool
class_name Palletes
extends Node

enum {PALLETE_CLASSIC, PALLETE_GRAYSCALE}

const PALLETES : Dictionary = {
	PALLETE_CLASSIC : [
		Color(0, 0, 0, 1),
		Color(0.0824, 0.0824, 0.0824, 1),
		Color(0.4039, 0.4039, 0.4039, 1),
		Color(0.5451, 0.5451, 0.5451, 1),
		Color(0.6196, 0.6196, 0.6196, 1),
		Color(0.0118, 0.6627, 0.9569, 1),
		Color(0.1294, 0.5882, 0.9529, 1),
		Color(1, 1, 1, 1),
		Color(1, 0.9216, 0.9333, 1),
		Color(1, 1, 1, 1),
		Color(1, 0.5961, 0, 1)
	],
	PALLETE_GRAYSCALE : [
		Color(0, 0, 0, 1),
		Color(0.102, 0.102, 0.102, 1),
		Color(0.2, 0.2, 0.2, 1),
		Color(0.302, 0.302, 0.302, 1),
		Color(0.4, 0.4, 0.4, 1),
		Color(0.502, 0.502, 0.502, 1),
		Color(0.6, 0.6, 0.6, 1),
		Color(0.702, 0.702, 0.702, 1),
		Color(0.8, 0.8, 0.8, 1),
		Color(0.902, 0.902, 0.902, 1),
		Color(1, 1, 1, 1)
	],
}

@export var pallete : Array = [
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1),
	Color(1, 1, 1)
]



@export var change_colors : bool = false
var previous_change_colors : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if change_colors != previous_change_colors:
		for i in range(pallete.size()):
			print("Color", pallete[i], ",")
		previous_change_colors = change_colors
