extends OmniLight3D

@export var noise: NoiseTexture3D
var time_passed: float = 0.0

func _process(delta: float) -> void:
	time_passed += delta
	
	var sampled_noise = noise.noise.get_noise_1d(time_passed)
	sampled_noise = abs(sampled_noise)
	
	light_energy = sampled_noise
