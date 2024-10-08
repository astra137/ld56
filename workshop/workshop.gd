extends Node2D


func spill(level: LevelBaseLayer) -> void:
	await %Cauldron.spill(level)
