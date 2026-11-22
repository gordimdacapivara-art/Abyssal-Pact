# GUIA DE COMPILAÇÃO E EXPORTAÇÃO — ABYSSAL PACT

**Versão da Engine:** Godot Engine v4.7.2.stable (ou compatível v4.x)  
**Projeto:** Abyssal Pact — RPG de Ação & Sobrevivência Demoníaca  
**Data:** 21 de Novembro de 2026  
**Status do Projeto:** Core, Sistemas, Geometrias 3D e Lógica 100% Homologados (28 Suítes / 4.884 Checks)

---

## 1. PRÉ-REQUISITOS DO SISTEMA

### 1.1. Binários do Godot
- **Godot Engine 4.7.2+ Standard (64-bit)**:
  - Windows: `Godot_v4.7.2-stable_win64.exe` e `Godot_v4.7.2-stable_win64_console.exe`.
  - Linux: `Godot_v4.7.2-stable_linux.x86_64`.
- **Templates de Exportação (Export Templates)**:
  - Devem corresponder com precisão à versão do executável (v4.7.2.stable).
  - Instalação no editor: `Editor -> Gerenciar Templates de Exportação (Manage Export Templates) -> Baixar e Instalar`.
  - Caminho padrão no Windows: `%APPDATA%\Godot\export_templates\4.7.2.stable\`
  - Caminho padrão no Linux: `~/.local/share/godot/export_templates/4.7.2.stable/`

### 1.2. Requisitos de Hardware para Compilação e Execução
- **CPU:** Quad-Core 3.0 GHz ou superior (x86_64).
- **RAM:** 8 GB mínimo (16 GB recomendado para bake de oclusão e lightmaps).
- **GPU:** Placa de vídeo compatível com Vulkan 1.2+ (Forward+ Rendering) ou Direct3D 12.
- **Armazenamento:** Mínimo de 10 GB livres para assets de áudio, texturas VRAM e builds.

---

## 2. ESTRUTURA DE PRESETS DE EXPORTAÇÃO

O arquivo `export_presets.cfg` (ou configuração via Editor) deve prever os seguintes alvos prioritários:

| Preset Name | Plataforma | Tipo | Executável de Saída |
|---|---|---|---|
| `Windows Desktop Client` | Windows Desktop (x86_64) | Gráfico (Forward+) | `build/windows/AbyssalPact.exe` |
| `Linux Desktop Client` | Linux/X11 (x86_64) | Gráfico (Forward+) | `build/linux/AbyssalPact.x86_64` |
| `Linux Dedicated Server` | Linux/X11 (x86_64) | Headless / Dedicated Server | `build/server/AbyssalPactServer.x86_64` |
| `Windows Dedicated Server` | Windows Desktop (x86_64) | Console / Headless | `build/server/AbyssalPactServer.exe` |

---

## 3. COMPILAÇÃO E EXPORTAÇÃO VIA CLI (LINHA DE COMANDO)

Todas as exportações podem ser disparadas sem abrir a interface gráfica do editor através de scripts de integração contínua (CI/CD) ou terminal local.

### 3.1. Exportação Windows Desktop (Client)
```powershell
# PowerShell (Windows)
& "C:\Path\To\Godot_v4.7.2-stable_win64_console.exe" `
    --headless `
    --path "c:\Users\fred_\Downloads\Abyssal Pact" `
    --export-release "Windows Desktop Client" "build/windows/AbyssalPact.exe"
```

### 3.2. Exportação Linux Dedicated Server (Headless)
```bash
# Bash (Linux CI/CD)
godot --headless --path /caminho/do/projeto --export-release "Linux Dedicated Server" build/server/AbyssalPactServer.x86_64
chmod +x build/server/AbyssalPactServer.x86_64
```

### 3.3. Flags de Otimização no Export
- `--export-release`: Remove símbolos de debug internos e otimiza bytecode GDScript compilado (`.gdc`).
- Certifique-se de que a opção de embutir o `.pck` dentro do binário esteja ativada caso queira uma distribuição em executável único, ou mantenha `AbyssalPact.pck` separado para facilidade de patching e DLCs regionais.

---

## 4. EXECUÇÃO DE SERVIDOR DEDICADO

O Abyssal Pact possui uma arquitetura dedicada para servidores privados cooperativos de até 16 jogadores simultâneos por mundo.

### 4.1. Comando para Iniciar Servidor Dedicado
```powershell
# Iniciar Servidor Privado na porta padrão 7777 (Windows)
& ".\build\server\AbyssalPactServer.exe" --headless --server --port 7777 --max-players 16 --world "MundoAlfa"
```

No Linux:
```bash
./build/server/AbyssalPactServer.x86_64 --headless --server --port 7777 --max-players 16 --world "MundoAlfa"
```

### 4.2. Variáveis de Ambiente e Overrides
É possível sobrescrever comportamentos do servidor via variáveis de ambiente no container ou sistema:
- `ABYSSAL_PORT`: Porta UDP de escuta do ENetMultiplayerPeer (Padrão: `7777`).
- `ABYSSAL_WORLD_ID`: Identificador único do mundo privado (usado nos diretórios de salvamento em `user://saves/`).
- `ABYSSAL_AZAROTH_CYCLE_HOURS`: Duração em horas do ciclo do World Boss (Padrão: `5.0`).
- `ABYSSAL_LOG_LEVEL`: Nível de detalhe do log (`DEBUG`, `INFO`, `WARNING`, `ERROR`).

---

## 5. HOMOLOGAÇÃO E BATERIA DE TESTES AUTOMATIZADOS

Antes de qualquer empacotamento ou liberação de nova build, execute a suíte de testes regressivos:

```powershell
# Execução Headless da Suíte Completa (28 Suítes / 4.884 Verificações)
& "C:\Users\fred_\Downloads\Godot_v4.7.2-stable_win64.exe (1)\Godot_v4.7.2-stable_win64_console.exe" `
    --headless `
    --path "c:\Users\fred_\Downloads\Abyssal Pact" `
    res://tests/run_tests.tscn
```

### Critério de Aceitação para Release:
- **Total de Falhas:** `0` (Zero).
- **Total de Suítes Executadas:** `28/28`.
- Saída esperada no terminal:
  ```text
  === RESUMO: 4884 checks, 0 falhas ===
  RESULTADO: TODOS OS TESTES PASSARAM
  ```

---

## 6. ESTRUTURA DE DIRETÓRIOS PARA DISTRIBUIÇÃO (CLIENT)

Para gerar o pacote final zipado de distribuição aos jogadores, a seguinte estrutura deve ser entregue:

```text
AbyssalPact_v1.0.0_Release/
├── AbyssalPact.exe                 (Executável principal)
├── AbyssalPact.pck                 (Pacote compilado de scripts, cenas e dados)
├── OpenXR/                         (Se compilado com suporte a VR - opcional)
├── d3d12/                          (Se empacotado com Agility SDK DirectX 12)
├── README.txt                      (Instruções rápidas de instalação)
├── RELEASE_CHECKLIST.md            (Checklist de homologação)
└── licenses/
    ├── Godot_License.txt
    └── ThirdParty_Licenses.txt
```

---

## 7. RESOLUÇÃO DE PROBLEMAS DE BUILD (TROUBLESHOOTING)

1. **Erro de VRAM ao Exportar Texturas:**
   - Caso ocorra falha de compressão ETC2/ASTC ou VRAM, verifique se o driver de vídeo está atualizado ou habilite a compressão multithreaded no Godot Editor.
2. **Warning de AnimationMixer Track Paths:**
   - Já suprimido no `project.godot` via `animation/warnings/check_invalid_track_paths=false` para garantir logs limpos em tempo de execução.
3. **Caminho de Salvamento:**
   - O jogo salva os arquivos no diretório `user://saves/` do Godot:
     - No Windows: `%APPDATA%\Godot\app_userdata\Abyssal Pact\saves\`
     - No Linux: `~/.local/share/godot/app_userdata/Abyssal Pact/saves/`
