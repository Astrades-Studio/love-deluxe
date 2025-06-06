@tool
extends TextureRect

@onready var noise_texture := texture

func _process(_delta: float) -> void:
	_cycle_noise()

func _cycle_noise():
	if noise_texture is NoiseTexture2D:
		var noise : FastNoiseLite = noise_texture.noise
		noise.seed = wrap(noise.seed + 1, 0, 7)
