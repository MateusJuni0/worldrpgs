class_name WeaponFamilyIcons
extends RefCounted
## Resolver unico para a mochila: o id do catalogo escolhe uma silhueta 32x32.

const PATHS := {
	"espada_recta": "res://assets/ui/icons/families/espada-recta.svg",
	"adaga": "res://assets/ui/icons/families/adaga.svg",
	"pesada_corte": "res://assets/ui/icons/families/pesada-corte.svg",
	"katana": "res://assets/ui/icons/families/katana.svg",
	"haste": "res://assets/ui/icons/families/haste.svg",
	"cajado": "res://assets/ui/icons/families/cajado.svg",
	"arco": "res://assets/ui/icons/families/arco.svg",
	"besta": "res://assets/ui/icons/families/besta.svg",
}


static func path_for(family_id: String) -> String:
	return String(PATHS.get(family_id, ""))


static func texture_for(family_id: String) -> Texture2D:
	var path := path_for(family_id)
	if path == "":
		return null
	return load(path) as Texture2D
