extends Node3D

var damage: int = 10
var lenght: int = 20 # For display in HUD only

func _ready() -> void:
	set_damage(damage)

func attack():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("attack")

func set_damage(amount: int):
	damage = amount
	$tip/Hitbox.damage = damage
