class_name HurtBox
extends Area3D

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))


func _on_area_entered(hitbox: HitBox) -> void:
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.get_damage())
