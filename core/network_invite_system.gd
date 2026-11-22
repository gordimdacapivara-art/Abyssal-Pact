class_name NetworkInviteSystem
extends RefCounted
## NetworkInviteSystem — Sistema de códigos de convite para mundos privados.
##
## REGRA FUNDAMENTAL: ABYSSAL PACT não possui servidores públicos ou relays pagos.
## Os mundos são exclusivamente privados, hospedados por um dos jogadores.
##
## O código de convite codifica os parâmetros necessários para conexão direta:
## - Endereço IP / Hostname (LAN ou IP público do anfitrião).
## - Porta UDP do servidor (padrão: 24565).
## - Identificador do mundo (World ID).
## - Token de segurança de sessão para validação no handshake.
## - Versão do protocolo de rede para compatibilidade.
##
## FORMATOS SUPORTADOS:
## 1. Token Completo: "AP-DIRECT-<Base64>" (contém endereço, porta, world_id e token).
## 2. Código Curto / LAN: "AP-<4 dígitos>" (requer descoberta LAN ou IP local conhecido).

const PREFIX_DIRECT := "AP-DIRECT-"
const PREFIX_SHORT := "AP-"
const PROTOCOL_VERSION := "1.0"

## Gera um código de convite completo contendo os dados de conexão direta.
static func generate_direct_code(address: String, port: int, world_id: StringName, session_token: String) -> String:
	var payload := {
		"v": PROTOCOL_VERSION,
		"a": address.strip_edges(),
		"p": port,
		"w": String(world_id),
		"t": session_token
	}
	var json_str := JSON.stringify(payload)
	var b64 := Marshalls.utf8_to_base64(json_str)
	return PREFIX_DIRECT + b64

## Gera um código curto humanamente legível (para identificação de sessão local).
static func generate_short_code() -> String:
	return "AP-%04d" % (randi() % 10000)

## Decodifica um código de convite e retorna um dicionário com os campos de conexão.
static func parse_invite_code(code: String) -> Dictionary:
	var clean := code.strip_edges()
	var result := {
		"valid": false,
		"is_direct": false,
		"address": "",
		"port": 24565,
		"world_id": &"",
		"session_token": "",
		"protocol_version": "",
		"short_code": "",
		"error": ""
	}

	if clean.is_empty():
		result["error"] = "Código de convite vazio."
		return result

	if clean.begins_with(PREFIX_DIRECT):
		var raw_b64 := clean.substr(PREFIX_DIRECT.length())
		var json_str := Marshalls.base64_to_utf8(raw_b64)
		if json_str.is_empty():
			result["error"] = "Formato Base64 inválido no código de convite."
			return result

		var json := JSON.new()
		var parse_err := json.parse(json_str)
		if parse_err != OK or not (json.data is Dictionary):
			result["error"] = "Estrutura corrompida no código de convite."
			return result

		var data: Dictionary = json.data
		result["valid"] = true
		result["is_direct"] = true
		result["protocol_version"] = str(data.get("v", ""))
		result["address"] = str(data.get("a", ""))
		result["port"] = int(data.get("p", 24565))
		result["world_id"] = StringName(str(data.get("w", "")))
		result["session_token"] = str(data.get("t", ""))

		if result["address"].is_empty() or result["port"] <= 0 or result["port"] > 65535:
			result["valid"] = false
			result["error"] = "Endereço ou porta inválidos dentro do código."
		return result

	elif clean.begins_with(PREFIX_SHORT):
		# Código curto de 4 dígitos ou alfanumérico
		result["valid"] = true
		result["is_direct"] = false
		result["short_code"] = clean
		return result

	result["error"] = "Prefixo de código de convite desconhecido (esperado AP- ou AP-DIRECT-)."
	return result

## Valida se o handshake recebido pelo host confere com a sessão ativa.
static func validate_handshake(received_token: String, expected_token: String, received_version: String) -> Dictionary:
	if not received_version.is_empty() and received_version != PROTOCOL_VERSION:
		return {
			"accepted": false,
			"reason": "Versão de protocolo incompatível (cliente: %s, host: %s)." % [received_version, PROTOCOL_VERSION]
		}
	if not expected_token.is_empty() and received_token != expected_token:
		return {
			"accepted": false,
			"reason": "Código ou token de segurança inválido para este mundo privado."
		}
	return {
		"accepted": true,
		"reason": "Acesso concedido."
	}
