extends Node3D

var damage: int = 1000

func _ready() -> void:
	$tip/Hitbox.damage = damage

func attack():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("attack")
