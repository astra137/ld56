extends StaticBody2D

@export var rotation_speed := 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate(rotation_speed * delta)
