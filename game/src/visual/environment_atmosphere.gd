class_name EnvironmentAtmosphere
extends RefCounted
## Fabrica unica de ambiente, nevoeiro, gradacao e luz por bioma.
##
## Os valores ajustaveis continuam a vir de graphics.json; esta camada decide
## apenas como os aplicar. Nao liga volumetria, SSAO, SSIL, SDFGI nem glow.

const FALLBACK_FOG := Color("8b96a3")
const FALLBACK_GROUND := Color("535f3e")
const FALLBACK_SUN := Color("ffebcc")


static func build_world_environment(
		preset: Dictionary, palette: Dictionary, biome: Dictionary) -> WorldEnvironment:
	var fog_colour := _biome_colour(biome, "nevoa", _palette_colour(
		palette, "fog", FALLBACK_FOG))
	var ground_colour := _palette_colour(palette, "ground", FALLBACK_GROUND)
	var sun_colour := _biome_colour(biome, "luz", FALLBACK_SUN)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = SkyAtmosphere.build(fog_colour, ground_colour, sun_colour)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.44
	environment.ambient_light_sky_contribution = 0.72
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY

	# [CODEX] Exponencial + altura conserva o corte de mundo do preset, mas deixa
	# primeiro plano limpo e acumula bruma junto ao chao. Alternativa descartada:
	# nevoeiro volumetrico, por custo e por piorar a leitura do combate.
	environment.fog_enabled = true
	environment.fog_mode = Environment.FOG_MODE_EXPONENTIAL
	environment.fog_light_color = fog_colour.darkened(0.06)
	environment.fog_light_energy = 0.76
	environment.fog_sun_scatter = 0.08
	environment.fog_height = 2.8
	environment.fog_height_density = 0.045
	environment.fog_aerial_perspective = 0.54
	environment.fog_sky_affect = 0.48

	apply_graphics(environment, preset)
	# O perfil barato e explicito: qualquer tecnica cara precisa de medicao e
	# de uma decisao nova, nao aparece ligada por omissao do motor.
	environment.ssao_enabled = false
	environment.ssil_enabled = false
	environment.sdfgi_enabled = false
	environment.glow_enabled = false
	environment.volumetric_fog_enabled = false

	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = environment
	return world_environment


static func build_sun(preset: Dictionary, biome: Dictionary) -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	# [CODEX] Sol a 18 graus, a sudoeste: fim de tarde reconhecivel e sombras
	# compridas. Alternativa descartada: ciclo continuo, ainda sem uso jogavel e
	# capaz de mudar a legibilidade de encontros durante a mesma tentativa.
	sun.rotation_degrees = Vector3(-18.0, 205.0, 0.0)
	sun.light_color = _biome_colour(biome, "luz", FALLBACK_SUN)
	sun.light_energy = 1.16
	sun.light_specular = 0.72
	sun.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_AND_SKY
	sun.shadow_enabled = bool(preset.get("shadows", true))
	sun.directional_shadow_max_distance = float(preset.get("shadow_distance", 30.0))
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	return sun


static func apply_graphics(environment: Environment, preset: Dictionary) -> void:
	# Estes valores sao lidos literalmente de graphics.json. A atmosfera
	# nao tem uma segunda gradacao escondida que torne os presets desonestos.
	environment.fog_density = float(preset.get("fog_density", 0.032))
	environment.adjustment_enabled = true
	environment.adjustment_brightness = float(preset.get("grade_brightness", 0.95))
	environment.adjustment_contrast = float(preset.get("grade_contrast", 1.14))
	environment.adjustment_saturation = float(preset.get("grade_saturation", 0.82))


static func _biome_colour(biome: Dictionary, key: String, fallback: Color) -> Color:
	var biome_palette := biome.get("paleta", {}) as Dictionary
	var value := String(biome_palette.get(key, ""))
	return Color(value) if value.is_valid_html_color() else fallback


static func _palette_colour(palette: Dictionary, key: String, fallback: Color) -> Color:
	var value := String(palette.get(key, ""))
	return Color(value) if value.is_valid_html_color() else fallback
