extends Node2D


signal level_complete(victory: bool)


@export var victory_points := 10

var tracking: Array[Furble] = []

var is_complete := true:
	set(value):
		is_complete = value
		if is_complete:
			level_complete.emit(current_points >= victory_points)

var current_points := 0:
	set(value):
		current_points = value
		if current_points >= victory_points:
			is_complete = true


func start_level(list: Array[Furble]) -> bool:
	assert(is_complete)
	if list.is_empty():
		return false
	is_complete = false
	current_points = 0
	tracking = list
	for body in tracking: body.tree_exiting.connect(_furble_ded.bind(body))
	return await level_complete


func _furble_ded(body: Furble) -> void:
	tracking.erase(body)
	if tracking.size() < victory_points - current_points and not is_complete:
		is_complete = true


func _on_goal_point_body_entered(body: Node2D) -> void:
	current_points += 1
	# Delete the node from the scene
	body.queue_free()
	%GoalSound.play()
