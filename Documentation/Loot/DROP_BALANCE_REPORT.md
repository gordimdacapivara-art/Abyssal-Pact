# RELATÓRIO DE BALANCEAMENTO, PROBABILIDADES E PROGRESSÃO
**Projeto:** Abyssal Pact | **Sistema:** Loot System (530 Inimigos)

---

## 1. REGRAS MATEMÁTICAS E ROLAGEM INDEPENDENTE
1. **Não Soma 100%:** Cada entrada da tabela de loot de um inimigo possui uma rolagem de probabilidade independente.
2. **Multi-Drop:** Um jogador que derrota um inimigo forte pode obter ouro garantido, um material comum (ex: 75%), um material incomum (ex: 35%) e um item raro (ex: 12%) na mesma vitória.
3. **Distribuição Uniforme de Quantidade:** Quando a rolagem tem sucesso, a quantidade entregue é sorteada aleatoriamente dentro do intervalo fechado `[min_quantity, max_quantity]`.

## 2. TABELA DE PROBABILIDADES POR CLASSIFICAÇÃO

| Classificação | Garantido | Comum | Incomum | Raro | Épico | Lendário | Equipamentos |
|:---|---:|---:|---:|---:|---:|---:|---:|
| **Comum** | 100% | 65–75% | 25–35% | 5–10% | 0.5–2% | 0.1–0.3% | 1.5–3.0% |
| **Forte** | 100% | 70–80% | 35–45% | 12–18% | 2.5–4.5% | 0.5–1.0% | 4.0–6.5% |
| **Elite** | 100% | 75–85% | 40–55% | 18–25% | 5.0–8.0% | 1.0–2.0% | 6.0–10.0% |
| **Raro** | 100% | 80–90% | 45–60% | 22–30% | 7.0–12.0% | 1.5–3.5% | 8.0–12.0% |
| **Chefe Supremo** | 100% | 85–100% | 55–70% | 30–45% | 15–25% | 5.0–9.0% | 15–20% |
| **Chefe Primordial** | 100% | 100% | 60–80% | 35–60% | 20–45% | 10–25% | 25–35% |

## 3. PROTEÇÃO CONTRA FARMING ABUSIVO
- **Respawn Timers Geográficos:** Inimigos comuns possuem tempo de respawn entre 90s e 180s.
- **Leash de Desengajamento:** Inimigos que saem do raio de combate retornam com velocidade 2.5x e regeneração total, impedindo kiting desleal.
- **Loot Instanciado em Multiplayer:** Em mundos privados de até 8 participantes, o Host distribui as rolagens individualmente para cada participante que contribuiu com dano (> 5% HP) ou assistência nos últimos 15 segundos.
