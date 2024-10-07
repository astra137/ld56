extends Node2D

const furble := preload("res://battle_screen/little_creature.tscn")


func _input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if event is InputEventKey and event.is_released():
		match event.keycode:
			KEY_1:
				spawn_furble(Furble.CreatureTypes.FIRE)
			KEY_2:
				spawn_furble(Furble.CreatureTypes.ICE)
			KEY_3:
				spawn_furble(Furble.CreatureTypes.EARTH)
			KEY_4:
				spawn_furble(Furble.CreatureTypes.ARCANE)
			KEY_5:
				spawn_furble(Furble.CreatureTypes.WATER)
			KEY_6:
				spawn_furble(Furble.CreatureTypes.ELECTRICITY)
			KEY_7:
				spawn_furble(Furble.CreatureTypes.WIND)
			KEY_8:
				spawn_furble(Furble.CreatureTypes.GRAVITY)

func spawn_furble(type: Furble.CreatureTypes):
	#var position = get_viewport().get_mouse_position()
	var position = get_global_mouse_position()

	var instance := furble.instantiate()

	(instance as Furble).type = type
	(instance as Furble).state = Furble.MovementStates.FALLING
	(instance as Furble).update_type()
	get_parent().add_child(instance)

	instance.global_position = position
