class_name TestCase
extends RefCounted
## Base de suítes de teste do Abyssal Pact (framework mínimo, sem addons).
##
## Contrato: cada suíte implementa execute() sequencial usando os helpers
## de asserção. Falhas são acumuladas; o TestHost reporta e define o código
## de saída.
##
## Padrão de captura de sinais (CAPTURA SÍNCRONA):
##   Godot 4.7 exige `await` na chamada de corrotinas — o padrão "waiter
##   adiantado" não compila. Como os eventos emitidos pelos gerenciadores
##   aqui testados são síncronos (mesma pilha de chamadas da ação), o
##   recorder é conectado ANTES da ação e os argumentos já estão
##   disponíveis na verificação:
##
##   var captura := capture(EventBus.character_created) # recorder armado
##   systems.create_character(...)                      # emite o sinal
##   var created_id: StringName = captura.first()[0]    # args do 1º emit
##
## `first()` retorna o Array de argumentos do primeiro emit; use [0] para
## sinais de um argumento. `count()` expõe quantos emits ocorreram.
## Para eventos assíncronos (conclusão de transição de cena), aguarde
## frames com `await wait_frames(n)` antes de ler a captura.

var host: Node # TestHost (fornece get_tree() e contexto de seção)
var section_label := ""

var _failures: PackedStringArray = PackedStringArray()
var _checks := 0

## Grava os emits de um sinal: cada emit vira um Array de argumentos.
class SignalCapture:
	extends RefCounted

	var received: Array = [] # Array[Array] — um Array de argumentos por emit
	var _signal: Signal
	var _handler: Callable

	## Argumentos do primeiro emit ([] quando nenhum emit ocorreu).
	func first() -> Array:
		return received[0] if not received.is_empty() else []

	func count() -> int:
		return received.size()

	## Desconecta o recorder (higiene; opcional).
	func release() -> void:
		if _handler.is_valid():
			_signal.disconnect(_handler)
			_handler = Callable()

# ------------------------------------------------------------------ EXECUÇÃO --

## Corpo da suíte (sequencial; pode usar await).
func execute() -> void:
	pass

func failure_count() -> int:
	return _failures.size()

func check_count() -> int:
	return _checks

func failures() -> PackedStringArray:
	return _failures

func section(label: String) -> void:
	section_label = label
	host.call("set_section", "%s :: %s" % [system_label(), label])

func system_label() -> String:
	return "TestCase"

# ------------------------------------------------------------------ ASSERÇÕES --

func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_fail(message)

func check_true(condition: bool, message: String) -> void:
	check(condition, message)

func check_false(condition: bool, message: String) -> void:
	check(not condition, message)

func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	_checks += 1
	if actual != expected:
		_fail("%s — esperado %s, obtido %s" % [message, expected, actual])

func check_ne(actual: Variant, not_expected: Variant, message: String) -> void:
	_checks += 1
	if actual == not_expected:
		_fail("%s — valor inesperado %s" % [message, actual])

func check_null(value: Variant, message: String) -> void:
	check(value == null, message)

func check_not_null(value: Variant, message: String) -> void:
	check(value != null, message)

## Compara códigos de erro da Godot (Error).
func check_err(actual: int, expected: int, message: String) -> void:
	_checks += 1
	if actual != expected:
		_fail("%s — esperado erro %d, obtido %d" % [message, expected, actual])

func _fail(message: String) -> void:
	var entry := "[FALHA] %s :: %s :: %s" % [system_label(), section_label, message]
	_failures.append(entry)
	host.call("report_failure", entry)

# ------------------------------------------------------------------- HELPERS --

## Acesso a sistema do registry pelo autoload Game (teste é o "hub" integrador).
func system(key: StringName) -> Node:
	return Game.get_system(key)

## Espera n frames do process loop (corrotina: usar com `await`).
func wait_frames(frames: int = 1) -> void:
	for i in frames:
		await host.get_tree().process_frame

## Arma um recorder para o sinal (chamar ANTES da ação que emite).
## Conecta um handler com a aridade exata do sinal (resolvida via
## EventBus.get_signal_list(); Signal não expõe get_argument_count()).
func capture(signal_value: Signal) -> SignalCapture:
	var record := SignalCapture.new()
	record._signal = signal_value
	match _signal_arity(signal_value):
		0:
			var handler := func() -> void:
				record.received.append([])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		1:
			var handler := func(a: Variant) -> void:
				record.received.append([a])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		2:
			var handler := func(a: Variant, b: Variant) -> void:
				record.received.append([a, b])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		3:
			var handler := func(a: Variant, b: Variant, c: Variant) -> void:
				record.received.append([a, b, c])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		4:
			var handler := func(a: Variant, b: Variant, c: Variant, d: Variant) -> void:
				record.received.append([a, b, c, d])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		5:
			var handler := func(a: Variant, b: Variant, c: Variant, d: Variant, e: Variant) -> void:
				record.received.append([a, b, c, d, e])
			record._handler = handler
			signal_value.connect(handler, CONNECT_ONE_SHOT)
		_:
			push_error("TestCase.capture: aridade de sinal não suportada: %s" % signal_value.get_name())
	return record

## Aritade do sinal consultando a declaração no EventBus autoload.
func _signal_arity(signal_value: Signal) -> int:
	var wanted := String(signal_value.get_name())
	for info in EventBus.get_signal_list():
		if String(info.get("name", "")) == wanted:
			return (info.get("args", []) as Array).size()
	return -1

## Encurta: acessa a cena corrente (para checagens de SceneManager).
func current_scene() -> Node:
	return host.get_tree().current_scene
