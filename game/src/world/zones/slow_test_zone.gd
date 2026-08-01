extends Node3D


func _ready() -> void:
	# Fixture: representa uma cena que faz construção pesada no thread principal.
	OS.delay_msec(25)
