extends Node3D

var damage: int = 1000
var lenght: int = 20 # Только для отображения в HUD 

func _ready() -> void:
	set_damage(damage)


func attack():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("attack")


func set_damage(amount: int):
	damage = amount
	$tip/Hitbox.damage = damage
