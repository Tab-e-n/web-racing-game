extends StaticBody2D


var active : bool = true


func _on_bump_detection_body_entered(body):
	active = false
	$coll.call_deferred("set_disabled", true)
	$bump_detection.call_deferred("set_monitoring", false)
	if $sprite.has_method("bumped"):
		$sprite.bumped(body)

