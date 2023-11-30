@tool
class_name Finish
extends Area2D


@export var lap_count : int = 3
@export var width : int = 512
var current_checkpoint : int = 0
var last_check_point : int = 0


func _ready():
	(get_tree().current_scene as Gameplay).set("lap_count", lap_count)
	$finish.region_rect.size = Vector2(width, 32)


func _physics_process(_delta):
	if Engine.is_editor_hint():
		$finish.region_rect.size = Vector2(width, 32)


func _on_body_entered(_body):
	if current_checkpoint == last_check_point:
		(get_tree().current_scene as Gameplay).player_did_a_lap()
		current_checkpoint = 0


func wrong_way():
	(get_tree().current_scene as Gameplay).wrong_way.emit()
