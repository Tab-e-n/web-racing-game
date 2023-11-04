extends Node2D

var current_track : Node2D = Node2D.new()
var track_name : String = ""

func _physics_process(delta):
	if track_name != Net.current_track_name:
		change_track(Net.current_track_name)

func change_track(new_track_name : String):
	current_track.queue_free()
	var packed = load("res://Tracks/" + new_track_name + ".tscn")
	current_track = packed.instantiate()
	add_child(current_track)
	track_name = new_track_name
