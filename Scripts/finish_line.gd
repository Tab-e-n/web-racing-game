extends Area2D

@export var width : int = 512

var current_checkpoint : int = 0
var last_check_point : int = 0

func _ready():
	$finish.region_rect.size = Vector2(width, 32)

func _on_body_entered(body):
	if current_checkpoint == last_check_point:
		if get_tree().current_scene.has_method("player_did_a_lap"):
			get_tree().current_scene.player_did_a_lap()
		current_checkpoint = 0
