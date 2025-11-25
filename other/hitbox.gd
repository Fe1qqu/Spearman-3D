class_name HitBox
extends Area3D

@export var damage: int = 1

signal hit_target(target: Node)

func _ready() -> void:
	# Prevent "UNUSED_SIGNAL" warning (signal is emitted externally from HurtBox)
	if false:
		emit_signal("hit_target", null)
