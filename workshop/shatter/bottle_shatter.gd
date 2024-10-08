extends Node2D


func _ready() -> void:
	var indices := [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
	indices.shuffle()
	$Shard1.which = indices[0]
	$Shard2.which = indices[1]
	$Shard3.which = indices[2]
	$Shard4.which = indices[3]

	for body in [$Cork, $Shard1, $Shard2, $Shard3, $Shard4]:
		body.linear_velocity = Vector2.UP.rotated(randf_range(-PI/2., PI/2.)) * 480.0
		body.angular_velocity = TAU

	await get_tree().create_timer(5.0).timeout
	if $BreakSound.playing:
		await $BreakSound.finished
