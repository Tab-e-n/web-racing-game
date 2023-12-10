@tool
class_name Palettes
extends Node

enum {PALETTE_CLASSIC, PALETTE_PINK, PALETTE_ICE, PALETTE_GRAYSCALE}

const PALETTES : Dictionary = {
	PALETTE_CLASSIC : [
		Color(0, 0, 0, 1),
		Color(0.0824, 0.0824, 0.0824, 1),
		Color(0.4039, 0.4039, 0.4039, 1),
		Color(0.5451, 0.5451, 0.5451, 1),
		Color(0.6196, 0.6196, 0.6196, 1),
		Color(0.1294, 0.5882, 0.9529, 1),
		Color(0.0118, 0.6627, 0.9569, 1),
		Color(1, 0.9216, 0.9333, 1),
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 1),
		Color(1, 0.5961, 0, 1)
	],
	PALETTE_GRAYSCALE : [
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
	PALETTE_PINK : [
		Color(0.1647, 0.0588, 0.1137, 1),
		Color(0.1647, 0.0588, 0.1137, 1),
		Color(0.2824, 0.0863, 0.1569, 1),
		Color(0.4431, 0.1451, 0.2431, 1),
		Color(0.6039, 0.1922, 0.3059, 1),
		Color(0.8314, 0.4078, 0.5373, 1),
		Color(0.9059, 0.502, 0.5608, 1),
		Color(0.7412, 0.8824, 0.9333, 1),
		Color(0.8588, 0.9608, 0.949, 1),
		Color(0.8588, 0.9608, 0.949, 1),
		Color(0.5529, 0.8745, 0.7176, 1)
	],
	PALETTE_ICE : [
		Color(0, 0.1137, 0.1804, 1),
		Color(0, 0.1137, 0.1804, 1),
		Color(0, 0.149, 0.3569, 1),
		Color(0, 0.2078, 0.4078, 1),
		Color(0, 0.2745, 0.4431, 1),
		Color(0.6118, 0.7765, 0.9529, 1),
		Color(0.7373, 0.851, 0.949, 1),
		Color(0.1176, 0.1882, 0.3725, 1),
		Color(0.1529, 0.2745, 0.4118, 1),
		Color(0.9843, 0.9922, 1, 1),
		Color(0.9843, 0.9922, 1, 1)
	],
}

@export var palette : Array = [
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
]



@export var change_colors : bool = false
@export var current_preset : int = PALETTE_CLASSIC
var previous_change_colors : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if change_colors != previous_change_colors:
		previous_change_colors = change_colors
		
		for i in range(palette.size()):
			print("Color", palette[i], ",")
		
		if current_preset >= 0:
			$PlaceholderCar3.material.set_shader_parameter("palette", PALETTES[current_preset])
		else:
			$PlaceholderCar3.material.set_shader_parameter("palette", palette)
