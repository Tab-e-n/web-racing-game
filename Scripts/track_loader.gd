extends Node2D


var current_track : Node2D = Node2D.new()
var track_name : String = ""


func _physics_process(_delta):
	if track_name != Net.current_track_name:
		change_track(Net.current_track_name)


func change_track(new_track_name : String):
	if current_track != null:
		current_track.queue_free()
	track_name = new_track_name
	if new_track_name == "":
		return
	
	var packed = load("res://Tracks/" + new_track_name + ".tscn")
	if packed == null:
		packed = load("res://Tracks/test_scene.tscn")
	current_track = packed.instantiate()
	add_child(current_track)
