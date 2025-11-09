extends Node3D

@onready var hitbox: HitBox = $tip/Hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var damage: int = 10
var lenght: int = 20 # For display in HUD only

func _ready() -> void:
	set_damage(damage)

func attack() -> void:
	if not animation_player.is_playing():
		animation_player.play("attack")

func set_damage(amount: int):
	damage = amount
	hitbox.damage = damage
