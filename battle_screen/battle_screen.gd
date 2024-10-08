extends Node2D

class_name LevelBaseLayer


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


func track_furble(body: Furble) -> void:
	tracking.push_back(body)
	body.level = self
	body.died.connect(_furble_died.bind(body))


func start_level() -> bool:
	is_complete = false
	current_points = 0
	check_victory.call_deferred()
	print('starting level with %d critters' % [tracking.size()])
	return await level_complete


func check_victory() -> void:
	if is_complete: return
	if tracking.size() < victory_points - current_points and not is_complete:
		is_complete = true


func _furble_died(body: Furble) -> void:
	tracking.erase(body)
	check_victory()


func _on_goal_point_body_entered(body: Node2D) -> void:
	current_points += 1
	# Delete the node from the scene
	body.queue_free()
	%GoalSound.play()
