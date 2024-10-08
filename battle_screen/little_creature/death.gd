extends Node2D


func _ready() -> void:
	%DisappearingSmoke.emitting = true
	await %DisappearingSmoke.finished
	queue_free()
