extends Node2D


const FURBLE = preload('res://workshop/furble.tscn')

var count := 0


func _process(_delta: float) -> void:
	%FPS.text = '%s\n%s' % [Engine.get_frames_per_second(), count]


func _physics_process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var body: RigidBody2D = FURBLE.instantiate()
		add_child(body)
		body.global_position = get_viewport().get_mouse_position()
		count += 1
