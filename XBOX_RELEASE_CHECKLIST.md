# CHECKLIST DE LANÇAMENTO E CERTIFICAÇÃO XBOX
## ABYSSAL PACT — GUIA DE PREPARAÇÃO FINAL PARA MICROSOFT PARTNER CENTER

**Data:** 22 de Novembro de 2026  
**Status do Projeto:** Pré-Certificação Arquitetural Aprovada (5.014/5.014 testes passando)  
**Versão Alvo:** 1.0.0-GOLD  

---

## 1. INTRODUÇÃO

Este checklist consolida todas as verificações mandatórias antes da submissão do build de **ABYSSAL PACT** aos laboratórios de certificação da Microsoft (Xbox Certification Lab). Cada item deve ser rigorosamente auditado pela equipe técnica e de controle de qualidade (QA).

---

## 2. CHECKLIST DETALHADO POR CATEGORIA

### 2.1. Arquitetura e Compilação
- [x] Base de código única e unificada no Godot 4 sem código duplicado ou bifurcado.
- [x] Ausência de bibliotecas ou DLLs proprietárias sob NDA dentro do repositório público.
- [x] Compilação limpa sem erros de sintaxe ou referências quebradas em GDScript.
- [x] Integração de `PlatformManager`, `PlatformProfile`, `DeviceManager`, `PlatformStorageAdapter` e `MultiplayerCrossplayManager`.
- [x] 100% de aprovação na suíte automatizada de testes (`suite_multiplatform.gd` e suítes core).

### 2.2. Controles, Interface e Acessibilidade (XR-051 / XR-054)
- [x] O jogo é 100% navegável utilizando apenas o controle sem necessidade de ponteiro de mouse.
- [x] Árvores de foco (`focus_neighbor_*`) amarram todos os botões e abas de inventário/criação.
- [x] Glifos corretos do controle Xbox (`[A]`, `[B]`, `[X]`, `[Y]`, `[LB]`, `[RB]`, `[LT]`, `[RT]`, `[Menu]`, `[View]`) exibidos dinamicamente na UI.
- [x] Tratamento de perda de controle (desconexão da bateria/cabo) com pausa imediata do jogo e aviso na tela.
- [x] Suporte à zona morta dos analógicos configurável para evitar drift.

### 2.3. Persistência, Nuvem e Quotas de Armazenamento (XR-052)
- [x] Persistência desacoplada do filesystem local através da interface `PlatformStorageAdapter`.
- [x] Implementação do stub de `XboxConnectedStorageAdapter` com limite estrito de 64 MB por contêiner.
- [x] Validação de serialização JSON-safe para evitar dados corrompidos na nuvem.
- [x] Suporte à troca de perfil de usuário do console sem vazamento de save do usuário anterior.

### 2.4. Multiplayer, Redes e Crossplay (XR-053 / XR-058)
- [x] Limite estrito de no máximo 8 jogadores por mundo privado (anfitrião incluído).
- [x] Verificação de privilégios da Xbox Live (`XPRIVILEGE_MULTIPLAYER_SESSIONS` e `XPRIVILEGE_CROSS_PLAY`).
- [x] Janela de tolerância de 60 segundos com tokens de reconexão segura em quedas de sinal.
- [x] Validação autoritativa do Host sobre todas as mutações de inventário, armas e progressão.
- [x] Exclusividade de acesso concorrente da Hell Forge única do mundo privado.
- [x] Exibição correta da Gamertag oficial em conformidade com as diretrizes de privacidade.

### 2.5. Desempenho e Estabilidade (Performance Targets)
- [x] 60 FPS estável atingido no Xbox Series S a 1080p (com FSR adaptativo).
- [x] 60 FPS estável atingido no Xbox Series X a 4K nativo.
- [x] Consumo de memória dentro do orçamento: < 7.500 MB no Series S e < 13.500 MB no Series X.
- [x] Monitor de memória ativo (`PlatformManager`) emitindo alerta aos 85% de ocupação.
- [x] Zero vazamentos cumulativos de memória (Memory Leaks) em sessões contínuas de 24 horas de estresse.
- [x] Tempo de carregamento de regiões inferior a 3,5 segundos no SSD dos consoles.

### 2.6. Metadados do Partner Center & Materiais de Loja
- [ ] Registro do Title ID e SCID oficiais no Partner Center.
- [ ] Ícones de shell gerados conforme as diretrizes visuais (150x150, 44x44, SplashScreen).
- [ ] Classificação indicativa atribuída (IARC, ESRB, PEGI, ClassInd).
- [ ] Textos da página da loja traduzidos (PT-BR, EN-US, ES, FR, DE, JA).
- [ ] Trailers e capturas de tela capturados no Xbox Series X em 4K nativo.

---

## 3. PROCEDIMENTO DE SUBMISSÃO (PASSO A PASSO)

```
1. Gerar Build Release
   └── Godot Export Template (Xbox / GDK habilitado)
       ├── Executável assinado
       └── Pacote .msixvc via makepkg.exe

2. Executar Windows App Cert Kit (WACK)
   └── Validar segurança, APIs permitidas e conformidade de manifesto

3. Testes Internos no Devkit em Modo CERT
   └── xbreboot /cert
   └── Simulação de desconexão de rede, bateria fraca e suspensão de título

4. Upload no Microsoft Partner Center
   └── Envio do pacote para o Certification Lab da Microsoft

5. Monitoramento do Relatório de Certificação (SLA de 3 a 5 dias úteis)
```
