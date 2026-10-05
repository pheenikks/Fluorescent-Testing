extends Node3D
## A failing tube: mostly lit, with bursts of stuttering dropouts.
## The light is excluded from the lightmap bake so it can change at runtime.

@export var min_interval := 1.5
@export var max_interval := 8.0

@onready var _light: SpotLight3D = $Light
@onready var _diffuser: MeshInstance3D = $Diffuser

var _material: StandardMaterial3D
var _base_light: float
var _base_emission: float


func _ready() -> void:
	_material = _diffuser.get_active_material(0).duplicate()
	_diffuser.material_override = _material
	_base_light = _light.light_energy
	_base_emission = _material.emission_energy_multiplier
	_run()


func _run() -> void:
	while true:
		await get_tree().create_timer(randf_range(min_interval, max_interval)).timeout
		if not is_inside_tree():
			return
		for i in randi_range(2, 7):
			_set_level(randf_range(0.0, 0.25))
			await get_tree().create_timer(randf_range(0.02, 0.12)).timeout
			_set_level(randf_range(0.6, 1.0))
			await get_tree().create_timer(randf_range(0.03, 0.2)).timeout
		if not is_inside_tree():
			return
		_set_level(1.0)


func _set_level(level: float) -> void:
	_light.light_energy = _base_light * level
	_material.emission_energy_multiplier = _base_emission * level
