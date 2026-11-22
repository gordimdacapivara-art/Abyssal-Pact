# REQUISITOS TÉCNICOS PARA PORTABILIDADE XBOX
## ABYSSAL PACT — GUIA DE CONFORMIDADE COM MICROSOFT GDK & XBOX SERIES X|S

**Data:** 22 de Novembro de 2026  
**Documento Técnico:** Porting Guide & XR Compliance  
**Motor Alvo:** Godot Engine 4.7.2 + Microsoft GDK (Game Development Kit)  

---

## 1. INTRODUÇÃO & ESCOPO LEGAL

Este documento detalha todos os pré-requisitos técnicos, regulatórios e de engenharia para transportar o jogo **ABYSSAL PACT** da versão PC Windows para os consoles **Xbox Series S** e **Xbox Series X**.

> **AVISO IMPORTANTE DE CONFORMIDADE:**  
> O código-fonte de Abyssal Pact foi preparado com arquitetura modular e camadas de abstração (`PlatformManager`, `PlatformStorageAdapter`, `DeviceManager`, `MultiplayerCrossplayManager`) que não violam termos de licenciamento. Nenhuma biblioteca proprietária não autorizada ou binário sob NDA do Microsoft GDK foi embutido neste repositório. O empacotamento final e envio à certificação exigem um acordo ativo no programa **ID@Xbox** e o uso das ferramentas oficiais da Microsoft.

---

## 2. PIPELINE DE DESENVOLVIMENTO & FERRAMENTAL MICROSOFT GDK

Para compilar e empacotar Abyssal Pact para Xbox, a equipe de engenharia deverá executar as seguintes etapas no ambiente registrado:

### 2.1. Configuração do Partner Center & IDs Oficiais
- **Title ID:** Identificador hexadecimal único atribuído no portal Microsoft Partner Center.
- **SCID (Service Configuration ID):** GUID para serviços de rede Xbox Live, estatísticas e Cross-Network Play.
- **Sandbox ID:** Ambiente de teste isolado (ex: `ABYS.1`, `CERT`).
- **Store Association:** Registro de metadados, classificação indicativa e pacotes de DLCs.

### 2.2. GDExtension do Microsoft GDK para Godot 4
A Godot 4 suporta compilação para consoles via **GDExtension** privada fornecida por estúdios certificados ou compilando o export template com a flag de console autorizada:
1. Clonar o repositório de templates oficiais autorizado via ID@Xbox.
2. Ligar as abstrações de `PlatformStorageAdapter` às funções da API `XGameSave`:
   - `XGameSaveInitializeProvider()`
   - `XGameSaveCreateContainer()`
   - `XGameSaveSubmitBlobWrite()`
3. Ligar os eventos de usuário do `DeviceManager` às chamadas `XUserAddAsync()` e `XUserGetId()`.

---

## 3. MAPEAMENTO DE REQUISITOS OBRIGATÓRIOS (XBOX REQUIREMENTS - XR)

| Requisito Xbox | Título da Regra | Solução Arquitetural Implementada em Abyssal Pact |
| :--- | :--- | :--- |
| **XR-051** | Controller Navigation & Focus | `DeviceManager.setup_focus_tree()` amarra automaticamente `focus_neighbor_*` em todos os botões e painéis, dispensando cursor do mouse. |
| **XR-052** | Connected Storage & Data Quota | `PlatformStorageAdapter.XboxConnectedStorageAdapterStub` impõe limite estrito de 64 MB e estrutura baseada em contêineres e blobs. |
| **XR-053** | Cross-Network Play & Privileges | `MultiplayerCrossplayManager.check_xbox_privileges()` valida `XPRIVILEGE_CROSS_PLAY` e `XPRIVILEGE_MULTIPLAYER_SESSIONS`. |
| **XR-054** | Loss of Controller Connectivity | O jogo detecta desconexão de gamepad via `joy_connection_changed`, pausando imediatamente o gameplay local e exibindo pop-up de reconexão. |
| **XR-055** | Process Lifecycle Management (PLM) | Suporte completo a Suspend/Resume. O jogo não descarta threads no suspend e restabelece conexões de rede em 60s no resume. |
| **XR-058** | Display of Gamertag & Presence | Nomes de exibição em sessões multiplayer refletem a Gamertag oficial retornada pelo subsistema Xbox Live. |
| **XR-112** | Fast Start & Chunking Layout | `layout.xml` estruturado com o `Chunk 0` contendo os sistemas de Boot, Criação de Personagem e Hub Inicial. |

---

## 4. ESTRUTURA DO ARQUIVO DE EMPACOTAMENTO (`MicrosoftGame.config`)

O manifesto do pacote UWP/GDK deve conter as seguintes diretivas obrigatórias:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Game configVersion="1">
    <Identity Name="AbyssalPact.Studios"
              Publisher="CN=ABYSSAL-PACT-CERT-KEY"
              Version="1.0.0.0"/>
    
    <ExecutableList>
        <Executable Name="AbyssalPact.exe"
                    TargetDeviceFamily="Scarlett"
                    Id="GameExecutable"/>
    </ExecutableList>
    
    <TitleId>YOUR_HEX_TITLE_ID</TitleId>
    <MSAAppId>YOUR_MSA_APP_ID</MSAAppId>
    
    <ShellVisuals DefaultDisplayName="Abyssal Pact"
                  PublisherDisplayName="Abyssal Team"
                  Square150x150Logo="Assets/Logo150.png"
                  Square44x44Logo="Assets/Logo44.png"
                  Description="ARPG Sombrio de Fantasia Abissal"
                  ForegroundText="light"
                  BackgroundColor="#0B090F"
                  SplashScreenImage="Assets/SplashScreen.png"/>
                  
    <ExtendedAttributeList>
        <ExtendedAttribute Name="Scid" Value="YOUR-SCID-GUID-HERE"/>
    </ExtendedAttributeList>
</Game>
```

---

## 5. REQUISITOS DE CHUNKING & FAST START (`layout.xml`)

Para atender ao Fast Start exigido no Xbox Series X|S:
- **Chunk 0 (Inicialização Imediata - ~3.5 GB):**
  - Motor Godot e runtime GDScript.
  - Cenas de Boot, Criação de Personagem e Telas de UI.
  - Catálogos centrais (40 raças, 80 sub-raças, 80 classes, 100 armas).
  - Região Hub e Forja Infernal (Hell Forge).
- **Chunk 1 (Continentes de Veyrath e Sylvaran - ~5.0 GB):**
  - As 20 regiões iniciais e bestiário regional associado.
- **Chunk 2 (Continentes de Khar'Duum e Nhal'Kora - ~6.0 GB):**
  - Regiões avançadas, 10 Primordiais e o confronto com Azaroth.

---

## 6. COMANDOS DE IMPLANTAÇÃO EM DEVKIT (XBOX SCARLETT)

Utilizando a linha de comando do GDK (`xbapp`):
```cmd
:: 1. Conectar ao Devkit
xbconnect 192.168.1.150

:: 2. Instalar o pacote .msixvc gerado pelo makepkg
xbapp install "D:\Builds\Xbox\AbyssalPact_1.0.0.0_x64.msixvc"

:: 3. Definir a sandbox de certificação
xbreboot /cert

:: 4. Iniciar a execução e anexar o depurador
xbapp launch AbyssalPact.Studios_1.0.0.0_x64__xxxx!GameExecutable
```
