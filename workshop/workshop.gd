extends Node2D


func _on_cauldron_clicked() -> void:
	printerr('_on_cauldron_clicked')


func spill() -> void:
	%Cauldron.spill()
