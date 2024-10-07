extends Node2D


func _on_goal_point_body_entered(body: Node2D) -> void:
	# Delete the node from the scene
	body.queue_free()
	%GoalSound.play()
