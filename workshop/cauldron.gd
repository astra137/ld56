extends CharacterBody2D


@export var spill_target: Marker2D


var is_spilling := false
var furbles: Array[Furble] = []
var bottles: Array[Bottle] = []


func gather_furbles() -> Array[Furble]:
	var list: Array[Furble] = []
	list.append_array(furbles)
	for bottle in bottles:
		list.append_array(bottle.get_furbles())
		bottle.shatter()
	return list


func awaken_furbles(list: Array[Furble]) -> void:
	for body in list:
		body.refresh_lifetime()
		body.is_legal_furble = true
		body.reparent(get_tree().root)


func spill() -> Array[Furble]:
	assert(not is_spilling)
	is_spilling = true
	var original := global_position
	var list := gather_furbles()
	for body in list: body.reparent(self)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, ^'global_position', spill_target.global_position, 1.0)
	tween.tween_property(self, ^'rotation', PI*0.99, 1.0)
	tween.chain()
	tween.tween_callback(awaken_furbles.bind(list))
	tween.tween_interval(2.0)
	tween.chain()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, ^'global_position', original, 1.0)
	tween.tween_property(self, ^'rotation', 0, 1.0)
	await tween.finished
	for body in furbles: body.queue_free()
	is_spilling = false
	return list


var gravity: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity") \
	* ProjectSettings.get_setting("physics/2d/default_gravity_vector")


func _physics_process(delta):
	if is_spilling: return
	if not is_on_floor():
		velocity += gravity * delta
	move_and_slide()


func _on_container_body_entered(body: Node2D) -> void:
	if body is Furble:
		furbles.push_back(body)
		body.state = Furble.MovementStates.BOTTLED
	if body is Bottle:
		bottles.push_back(body)


func _on_container_body_exited(body: Node2D) -> void:
	if body is Furble:
		furbles.erase(body)
		body.state = Furble.MovementStates.FALLING
	if body is Bottle:
		bottles.erase(body)
