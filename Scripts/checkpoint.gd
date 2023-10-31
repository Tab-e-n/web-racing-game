extends Area2D

@onready var finish : Node2D = get_parent()
var checkpoint_number : int

func _ready():
	finish.last_check_point += 1
	checkpoint_number = finish.last_check_point


func _on_body_entered(_body):
	if finish.current_checkpoint == checkpoint_number - 1:
		finish.current_checkpoint = checkpoint_number
#		print(checkpoint_number)
#	else:
#		print("wrong, ", checkpoint_number)
