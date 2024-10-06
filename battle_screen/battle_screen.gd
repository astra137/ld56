extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var furbles := get_tree().get_nodes_in_group("furble")

	for furble in furbles:
		(furble as Furble).state = Furble.MovementStates.FALLING


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_goal_point_body_entered(body: Node2D) -> void:
	# Delete the node from the scene
	body.queue_free()
