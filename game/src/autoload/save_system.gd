extends Node
## Persistencia versionada do estado do personagem e do mundo.
##
## O catalogo continua a viver no GameData; o save guarda apenas estado mutavel e
## ids estaveis que apontam para esse catalogo. Fonte: spec/59-saves.md.

const CURRENT_FORMAT_VERSION := 1
const SAVE_DIR := "user://saves"

var last_error := ""
var last_load_recovered := false
var last_recovery_source := ""
var last_load_migrated := false
var active_slot := 0

signal save_completed(path: String)
signal save_failed(path: String, message: String)
signal recovery_completed(path: String, source: String)


func create_save(profile_id: String, class_id: String, identity_overrides := {}) -> Dictionary:
	var attributes := GameData.class_attributes(class_id).duplicate(true)
	attributes.erase("display_name")
	var loadouts: Dictionary = GameData.weapons.get("loadouts", {}) as Dictionary
	var loadout: Dictionary = (loadouts.get(class_id, {}) as Dictionary).duplicate(true)
	var identity := {
		"name": "",
		"class_id": class_id,
		"appearance": (GameData.appearance.get("default", {}) as Dictionary).duplicate(true),
	}
	for key: Variant in identity_overrides.keys():
		if key != "class_id":
			identity[key] = identity_overrides[key]
	return {
		"format_version": CURRENT_FORMAT_VERSION,
		"content_revision": String(ProjectSettings.get_setting("application/config/version", "prototype")),
		"saved_at_unix": int(Time.get_unix_time_from_system()),
		"character": {
			"profile_id": profile_id,
			"identity": identity,
			"progression": {
				"level": 1,
				"souls_held": 0,
				"attributes": attributes,
				"unlocked_skills": [],
				"known_spells": [],
				"scrolls": [],
				"flask_upgrades": {},
				"verbs": [],
				"boss_rewards_claimed": [],
				"collected_placed_items": [],
				"applied_event_ids": [],
			},
			"inventory": {
				"items": {},
				"equipment": {
					"main": loadout.get("main", null),
					"offhand": loadout.get("offhand", null),
					"armor": loadout.get("pecas", []),
					"rings": [],
					"spell_favorites": [],
				},
				"quick_slots": [],
				"weapon_upgrades": {},
				"spell_upgrades": {},
			},
			"checkpoint": {"zone_id": "", "rest_point_id": ""},
			"death": {"soul_stain": null},
		},
		"world": {
			"owner_profile_id": profile_id,
			"cycle": 0,
			"bosses_defeated": [],
			"shortcuts_open": [],
			"rest_points_discovered": [],
			"chests_opened": [],
			"enemy_respawns": {},
			"loot_decks": {},
			"zone_flags": {},
			"map": {"exploration": {}, "marks_by_profile": {}},
			"reward_receipts": [],
		},
	}


func slot_path(slot: int) -> String:
	return "%s/slot_%02d.json" % [SAVE_DIR, slot]


func new_game(profile_id: String, class_id: String, slot: int = 0,
		identity_overrides := {}) -> bool:
	active_slot = slot
	var state := create_save(profile_id, class_id, identity_overrides)
	GameData.replace_save_state(state)
	return save_current(slot)


func save_current(slot: int = -1) -> bool:
	var target_slot := active_slot if slot < 0 else slot
	active_slot = target_slot
	var path := slot_path(target_slot)
	var state := GameData.save_state_snapshot()
	var saved := save_to_path(path, state)
	if saved:
		GameData.replace_save_state(state)
		save_completed.emit(path)
	else:
		save_failed.emit(path, last_error)
	return saved


## Publica a recompensa inteira numa unica geracao de save. Se a escrita ou a
## verificacao falhar, o estado em memoria volta exactamente ao snapshot anterior.
func commit_enemy_defeat(enemy_id: String, event_id: String, seed_value: int,
		receiver_class_id: String, slot: int = -1) -> Dictionary:
	var before := GameData.save_state_snapshot()
	if before.is_empty():
		return {"status": "no_active_save"}
	var working := before.duplicate(true)
	var receipt := GameData.reward_enemy_defeat(
		working, enemy_id, event_id, seed_value, receiver_class_id)
	if String(receipt.get("status", "")) != "awarded":
		return receipt
	GameData.replace_save_state(working)
	if not save_current(slot):
		GameData.replace_save_state(before)
		return {
			"status": "save_failed",
			"enemy_id": enemy_id,
			"event_id": event_id,
			"message": last_error,
		}
	return receipt


func load_slot(slot: int = 0) -> Dictionary:
	active_slot = slot
	var path := slot_path(slot)
	var state := load_from_path(path)
	if last_load_recovered:
		recovery_completed.emit(path, last_recovery_source)
	return state


func save_to_path(path: String, state: Dictionary) -> bool:
	last_error = ""
	state["format_version"] = CURRENT_FORMAT_VERSION
	state["saved_at_unix"] = int(Time.get_unix_time_from_system())
	if not _has_required_sections(state):
		return _fail("O estado nao tem as seccoes obrigatorias character/world")
	state["checksum_sha256"] = _checksum_for(state)
	var parent := ProjectSettings.globalize_path(path.get_base_dir())
	var mkdir_error := DirAccess.make_dir_recursive_absolute(parent)
	if mkdir_error != OK and mkdir_error != ERR_ALREADY_EXISTS:
		return _fail("Nao foi possivel criar a pasta do save: %s" % error_string(mkdir_error))

	var temporary_path := path + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _fail("Nao foi possivel abrir o ficheiro temporario: %s" % error_string(FileAccess.get_open_error()))
	file.store_string(JSON.stringify(state, "\t", true))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return _fail("Falha ao escrever o ficheiro temporario: %s" % error_string(write_error))
	if String(_decode_candidate(temporary_path).get("status", "")) != "ok":
		return _fail("O ficheiro temporario nao passou a verificacao antes do commit")

	return _commit_temporary(path, temporary_path)


func load_from_path(path: String, apply_to_game_data: bool = true) -> Dictionary:
	last_error = ""
	last_load_recovered = false
	last_recovery_source = ""
	last_load_migrated = false
	var active := _decode_candidate(path)
	if String(active.get("status", "")) == "future":
		_fail("O save foi criado por uma versao mais recente do jogo")
		return {}
	if String(active.get("status", "")) == "ok":
		var state: Dictionary = active.get("state", {}) as Dictionary
		last_load_migrated = bool(active.get("migrated", false))
		if last_load_migrated and not save_to_path(path, state):
			return {}
		_apply_loaded_state(state, apply_to_game_data)
		return state

	# Um rename interrompido pode deixar apenas o backup; um primeiro save pode
	# deixar apenas um temporario completo. O backup tem sempre precedencia.
	for candidate_path: String in [path + ".bak", path + ".tmp"]:
		var candidate := _decode_candidate(candidate_path)
		var candidate_status := String(candidate.get("status", ""))
		if candidate_status == "future":
			_fail("Existe uma copia do save criada por uma versao mais recente do jogo")
			return {}
		if candidate_status != "ok":
			continue
		if FileAccess.file_exists(path) and not _quarantine(path):
			return {}
		var recovered: Dictionary = candidate.get("state", {}) as Dictionary
		if not save_to_path(path, recovered):
			return {}
		last_load_recovered = true
		last_recovery_source = candidate_path
		last_load_migrated = bool(candidate.get("migrated", false))
		_apply_loaded_state(recovered, apply_to_game_data)
		return recovered

	if FileAccess.file_exists(path) and not _quarantine(path):
		return {}
	if String(active.get("status", "")) == "missing":
		_fail("Save inexistente: %s" % path)
	else:
		_fail("Save corrompido sem copia recuperavel: %s" % path)
	return {}


func _commit_temporary(path: String, temporary_path: String) -> bool:
	var absolute_path := ProjectSettings.globalize_path(path)
	var absolute_temporary := ProjectSettings.globalize_path(temporary_path)
	var backup_path := path + ".bak"
	var absolute_backup := ProjectSettings.globalize_path(backup_path)
	var rotated_previous := false

	if FileAccess.file_exists(path):
		var active_status := String(_decode_candidate(path).get("status", ""))
		if active_status == "future":
			return _fail("Recuso substituir um save de uma versao mais recente")
		if active_status == "ok":
			if FileAccess.file_exists(backup_path):
				var remove_error := DirAccess.remove_absolute(absolute_backup)
				if remove_error != OK:
					return _fail("Nao foi possivel rodar o backup: %s" % error_string(remove_error))
			var backup_error := DirAccess.rename_absolute(absolute_path, absolute_backup)
			if backup_error != OK:
				return _fail("Nao foi possivel preservar a geracao anterior: %s" % error_string(backup_error))
			rotated_previous = true
		elif not _quarantine(path):
			return false

	var rename_error := DirAccess.rename_absolute(absolute_temporary, absolute_path)
	if rename_error == OK:
		return true

	# Se o segundo rename falhar, o ultimo estado confirmado volta ao lugar.
	if rotated_previous and not FileAccess.file_exists(path):
		DirAccess.rename_absolute(absolute_backup, absolute_path)
	return _fail("Falha ao confirmar o save: %s" % error_string(rename_error))


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	if typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return (json.data as Dictionary).duplicate(true)


func _decode_candidate(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": "missing"}
	var state := _read_json_dictionary(path)
	if state.is_empty():
		return {"status": "corrupt"}
	var version := 0
	if state.has("format_version"):
		var raw_version: Variant = state["format_version"]
		if typeof(raw_version) not in [TYPE_INT, TYPE_FLOAT]:
			return {"status": "corrupt"}
		var numeric_version := float(raw_version)
		if numeric_version < 0.0 or numeric_version != floorf(numeric_version):
			return {"status": "corrupt"}
		version = int(numeric_version)
	if version > CURRENT_FORMAT_VERSION:
		return {"status": "future"}
	if version == CURRENT_FORMAT_VERSION and not _checksum_is_valid(state):
		return {"status": "corrupt"}
	var migrated := false
	while version < CURRENT_FORMAT_VERSION:
		match version:
			0:
				state = _migrate_v0_to_v1(state)
				version = 1
				migrated = true
			_:
				return {"status": "corrupt"}
	if not _has_required_sections(state):
		return {"status": "corrupt"}
	if migrated:
		state["checksum_sha256"] = _checksum_for(state)
	return {"status": "ok", "state": state, "migrated": migrated}


func _migrate_v0_to_v1(old_state: Dictionary) -> Dictionary:
	var legacy := old_state.duplicate(true)
	if legacy.has("player") and not legacy.has("character"):
		legacy["character"] = legacy["player"]
		legacy.erase("player")
	var character: Dictionary = legacy.get("character", {}) as Dictionary
	var identity: Dictionary = character.get("identity", {}) as Dictionary
	var profile_id := String(character.get("profile_id", "legacy"))
	var class_id := String(identity.get("class_id", "warrior"))
	var migrated := _merge_with_defaults(create_save(profile_id, class_id), legacy)
	migrated["format_version"] = 1
	return migrated


func _merge_with_defaults(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var merged := defaults.duplicate(true)
	for key: Variant in loaded.keys():
		if typeof(loaded[key]) == TYPE_DICTIONARY and typeof(merged.get(key)) == TYPE_DICTIONARY:
			merged[key] = _merge_with_defaults(merged[key] as Dictionary, loaded[key] as Dictionary)
		else:
			merged[key] = loaded[key]
	return merged


func _has_required_sections(state: Dictionary) -> bool:
	return int(state.get("format_version", 0)) == CURRENT_FORMAT_VERSION \
		and typeof(state.get("character")) == TYPE_DICTIONARY \
		and typeof(state.get("world")) == TYPE_DICTIONARY


func _checksum_for(state: Dictionary) -> String:
	var payload := state.duplicate(true)
	payload.erase("checksum_sha256")
	# JSON normaliza os tipos numericos ao ler. Calculamos sobre essa mesma
	# representacao para 1 e 1.0 nao produzirem checksums diferentes no round-trip.
	var normalised: Variant = JSON.parse_string(JSON.stringify(payload, "", true))
	return JSON.stringify(normalised, "", true).sha256_text()


func _checksum_is_valid(state: Dictionary) -> bool:
	var stored := String(state.get("checksum_sha256", ""))
	return stored.length() == 64 and stored == _checksum_for(state)


func _quarantine(path: String) -> bool:
	var corrupt_path := path + ".corrupt"
	var absolute_corrupt := ProjectSettings.globalize_path(corrupt_path)
	if FileAccess.file_exists(corrupt_path):
		var remove_error := DirAccess.remove_absolute(absolute_corrupt)
		if remove_error != OK:
			return _fail("Nao foi possivel rodar o save corrompido: %s" % error_string(remove_error))
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(path), absolute_corrupt)
	if rename_error != OK:
		return _fail("Nao foi possivel preservar o save corrompido: %s" % error_string(rename_error))
	return true


func _apply_loaded_state(state: Dictionary, apply_to_game_data: bool) -> void:
	if apply_to_game_data:
		GameData.replace_save_state(state)


func _fail(message: String) -> bool:
	last_error = message
	push_error("[SaveSystem] %s" % message)
	return false
