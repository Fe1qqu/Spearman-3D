extends Node3D

var damage: int = 10

func attack():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("attack")
