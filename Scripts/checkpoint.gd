extends Area2D


var finish : Finish
var checkpoint_number : int

@onready var debug_visual : Sprite2D = $visual


func _ready():
	var parent = get_parent()
	if not parent is Finish:
		queue_free()
		return
	finish = parent
	finish.last_check_point += 1
	
	debug_visual.visible = false
	
	checkpoint_number = finish.last_check_point


func _physics_process(_delta):
	debug_visual.visible = Global.debug_mode


func _on_body_entered(_body):
	if finish.current_checkpoint == checkpoint_number - 1:
		finish.current_checkpoint = checkpoint_number
#		print(checkpoint_number)
#	else:
#		print("wrong, ", checkpoint_number)
