class_name VendorNpc
extends Node3D
## Fronteira de interacção, não uma decisão sobre mortalidade. Qualquer sistema
## de NPC pode activar/desactivar a troca sem mover stock nem migrar o save.

signal shop_requested(vendor_id: String, actor: Node, vendor: VendorNpc)
signal trade_unavailable(reason: String)

@export var vendor_id := ""

var trade_enabled := true
var unavailable_reason := ""


func interaction_prompt() -> String:
	var binding := "E"
	if Engine.has_singleton("SettingsSystem"):
		binding = String(Engine.get_singleton("SettingsSystem").call(
			"binding_label", "interact"))
	elif get_node_or_null("/root/SettingsSystem") != null:
		binding = String(get_node("/root/SettingsSystem").call("binding_label", "interact"))
	return "%s — falar / negociar" % binding.to_upper()


func interact(actor: Node) -> bool:
	if not trade_enabled:
		trade_unavailable.emit(unavailable_reason)
		return false
	shop_requested.emit(vendor_id, actor, self)
	return true


func set_trading_enabled(value: bool, reason := "") -> void:
	trade_enabled = value
	unavailable_reason = reason
