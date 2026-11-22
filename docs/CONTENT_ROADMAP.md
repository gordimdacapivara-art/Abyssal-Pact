# Plano de documentação de conteúdo

Este documento organiza o conteúdo planejado sem inventar fichas, estatísticas ou decisões que ainda não foram registradas.

## Catálogo de conteúdo

| Área | Escopo mencionado no planejamento | Próximo passo |
| --- | --- | --- |
| Raças e sub-raças | 40 raças foram mencionadas como meta de conteúdo | Criar catálogo, identidade visual, atributos e sub-raças aprovadas |
| Classes | 80 classes foram mencionadas como meta de conteúdo | Definir função, recursos, habilidades e progressão de cada classe |
| Monstros | 300 monstros foram mencionados | Criar fichas individuais, comportamento, regiões e loot |
| Demônios | 230 demônios foram mencionados | Criar fichas individuais e relações com os Primordiais |
| Itens e armas | Categorias amplas de equipamentos e armas | Definir categorias, atributos, raridade, receitas e modelos |
| Continentes e mapas | Múltiplos continentes planejados | Documentar regiões, biomas, pontos de interesse e conexões |

Os totais acima são metas mencionadas no planejamento e não significam que o conteúdo já esteja implementado.

## Modelo recomendado para fichas

### Criatura

- ID estável
- Nome
- Categoria
- Descrição e identidade
- Região de aparição
- Comportamento
- Nível ou faixa de desafio (a definir)
- Habilidades
- Resistências e fraquezas (a definir)
- Tabela de drops
- Referências de modelo, animação e áudio
- Estado: proposta / aprovada / implementada / testada

### Drop

- ID do item
- Quantidade mínima e máxima
- Chance de obtenção
- Condições especiais
- Fonte da informação ou decisão de design

As probabilidades devem ser verificadas para que a tabela de cada criatura tenha comportamento esperado e não produza resultados impossíveis.

### Classe

- ID estável
- Nome
- Identidade e fantasia de jogo
- Papel pretendido
- Atributos relevantes
- Recursos
- Habilidades e modificadores
- Progressão
- Equipamentos permitidos
- Referências visuais
- Estado

### Raça e sub-raça

- ID estável
- Nome
- Descrição
- Cultura e origem
- Características de gameplay aprovadas
- Sub-raças relacionadas
- Referências de modelo e animação
- Estado

## Organização futura sugerida

```text
docs/
├── world/
│   ├── continents/
│   └── regions/
├── characters/
│   ├── races/
│   └── classes/
├── creatures/
│   ├── monsters/
│   └── demons/
├── equipment/
│   ├── weapons/
│   └── items/
└── systems/
```

Criar arquivos individuais e dados de implementação em lotes revisáveis, preservando IDs estáveis e evitando duplicações.
