class_name SkyAtmosphere
extends RefCounted
## Ceu procedural leve para os biomas exteriores.
##
## Nao usa HDRI nem shader de nuvens por pixel. Uma cobertura pequena e gerada
## uma vez no arranque e o ProceduralSkyMaterial faz o resto no shader leve do
## proprio motor.

const COVER_WIDTH := 256
const COVER_HEIGHT := 64
const COVER_SEED := 1701

static var _cloud_cover: Texture2D


static func build(fog_colour: Color, ground_colour: Color, sun_colour: Color) -> Sky:
	var material := ProceduralSkyMaterial.new()
	# [CODEX] O zenite frio e o horizonte ligeiramente quente dizem "fim de
	# tarde humido" sem uma segunda luz. Alternativa descartada: PhysicalSky,
	# mais realista mas sem vantagem suficiente para a Iris Xe.
	var cold_zenith := fog_colour.darkened(0.68).lerp(Color("0c111a"), 0.58)
	var warm_horizon := fog_colour.lerp(sun_colour, 0.12).darkened(0.04)
	material.sky_top_color = cold_zenith
	material.sky_horizon_color = warm_horizon
	material.sky_curve = 0.07
	material.sky_energy_multiplier = 0.70
	material.ground_bottom_color = ground_colour.darkened(0.58)
	material.ground_horizon_color = fog_colour.darkened(0.16)
	material.ground_curve = 0.04
	material.ground_energy_multiplier = 0.48
	material.sun_angle_max = 4.5
	material.sun_curve = 0.32
	material.use_debanding = true
	material.sky_cover = _get_cloud_cover()
	material.sky_cover_modulate = fog_colour.darkened(0.48)

	var sky := Sky.new()
	# A radiancia serve a luz ambiente, nao a imagem de fundo. 128 e suficiente
	# para formas largas e evita gastar memoria numa reflexao que Brumal esconde.
	sky.radiance_size = Sky.RADIANCE_SIZE_128
	sky.sky_material = material
	return sky


static func _get_cloud_cover() -> Texture2D:
	if _cloud_cover != null:
		return _cloud_cover
	var noise := FastNoiseLite.new()
	noise.seed = COVER_SEED
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_octaves = 4
	noise.fractal_gain = 0.54
	noise.fractal_lacunarity = 2.05
	var image := noise.get_seamless_image(
		COVER_WIDTH, COVER_HEIGHT, false, false, 0.16, true)
	image.convert(Image.FORMAT_RGBA8)
	# A cobertura e aditiva no ProceduralSkyMaterial. Preto preserva o ceu base;
	# apenas as massas claras recebem o cinzento da bruma e desenham nuvens.
	for y: int in COVER_HEIGHT:
		for x: int in COVER_WIDTH:
			var sample := image.get_pixel(x, y).r
			var cloud := smoothstep(0.50, 0.61, sample)
			image.set_pixel(x, y, Color(cloud, cloud, cloud, 1.0))
	_cloud_cover = ImageTexture.create_from_image(image)
	return _cloud_cover
