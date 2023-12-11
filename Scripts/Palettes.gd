@tool
class_name Palettes
extends Node

enum {PALETTE_CLASSIC, PALETTE_BLUE_MARBLE, PALETTE_GRASS, PALETTE_ORANGE, PALETTE_DESERT, PALETTE_PINK, PALETTE_ICE, PALETTE_GRAYSCALE}

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
	PALETTE_GRASS : [
		Color(0.0196, 0.0824, 0, 1),
		Color(0.0196, 0.0824, 0, 1),
		Color(0.0627, 0.1843, 0.0941, 1),
		Color(0.098, 0.2549, 0.0706, 1),
		Color(0.1294, 0.3176, 0, 1),
		Color(0.298, 0.5059, 0.2275, 1),
		Color(0.3608, 0.6039, 0.1961, 1),
		Color(0.8353, 0.7176, 0.4235, 1),
		Color(0.9451, 0.8667, 0.5686, 1),
		Color(0.9451, 0.8667, 0.5686, 1),
		Color(0.9216, 0.7804, 0.2039, 1)
	],
	PALETTE_BLUE_MARBLE : [
		Color(0, 0.0118, 0.1451, 1),
		Color(0, 0.0118, 0.1451, 1),
		Color(0, 0.1412, 0.2745, 1),
		Color(0.0863, 0.2353, 0.2431, 1),
		Color(0.1412, 0.2902, 0.1804, 1),
		Color(0.1255, 0.2431, 0.5216, 1),
		Color(0.2824, 0.3686, 0.7333, 1),
		Color(0.3137, 0.6627, 0.2824, 1),
		Color(0.5176, 0.749, 0.349, 1),
		Color(0.8824, 0.8941, 0.5333, 1),
		Color(0.8745, 0.9098, 0.2745, 1)
	],
	PALETTE_ORANGE : [
		Color(0.1059, 0.0314, 0, 1),
		Color(0.1059, 0.0314, 0, 1),
		Color(0.2118, 0.0863, 0.0863, 1),
		Color(0.2667, 0.1176, 0.0627, 1),
		Color(0.3373, 0.1569, 0, 1),
		Color(0.7686, 0.302, 0.1765, 1),
		Color(0.9412, 0.3961, 0.1686, 1),
		Color(0.9059, 0.6588, 0.4627, 1),
		Color(0.9529, 0.7647, 0.5725, 1),
		Color(0.9529, 0.7647, 0.5725, 1),
		Color(0.9765, 0.8275, 0.4353, 1)
	],
	PALETTE_DESERT : [
		Color(0.0627, 0.0627, 0, 1),
		Color(0.1804, 0.0078, 0.1373, 1),
		Color(0.1804, 0.0078, 0.1373, 1),
		Color(0.1804, 0.0078, 0.1373, 1),
		Color(0.1804, 0.0078, 0.1373, 1),
		Color(0.8196, 0.6431, 0.4078, 1),
		Color(0.9451, 0.8078, 0.4471, 1),
		Color(0.5804, 0.149, 0.6941, 1),
		Color(0.7333, 0.3647, 0.7216, 1),
		Color(0.9686, 0.8824, 0.9647, 1),
		Color(0.898, 0.3922, 0.549, 1)
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
