# ⚙️🥩 Manivela Engine

![Language](https://img.shields.io/badge/Made_with-Beef_Lang-red?style=for-the-badge&logo=target&logoColor=white&labelColor=black)
![Library](https://img.shields.io/badge/Graphics-SDL3-blue?style=for-the-badge&logo=sdl&logoColor=white&labelColor=black)
![Category](https://img.shields.io/badge/Category-Game_Engine-lightgrey?style=for-the-badge&labelColor=black)

> **Um motor 2D de alta performance usando a alta performance da Beef Lang.**

O **Manivela Engine** é um motor de jogo personalizado desenvolvido na linguagem **Beef**, com foco em performance bruta e controlo rigoroso de memória. Utilizando o **SDL3** e **SDL3_image**, o motor oferece uma base sólida para a criação de jogos 2D rápidos e responsivos.

Incluído neste repositório está o *Endsward Ranch*, uma demonstração técnica que coloca à prova todos os sistemas do motor em um cenário de combate real.

## 🛠️ Funcionalidades Principais 🍖

| Feature | Implementação | Descrição |
| :--- | :--- | :--- |
| **🥩 Core Loop & Render** | `Engine.bf` | Ciclo principal de jogo com gestão de frames a 60+ FPS e renderização acelerada por hardware via SDL3. |
| **🔄 Física & Resolução** | `EndswardRanch.bf` | Sistema de colisão AABB com cálculo de massa e vetores de repulsão (*knockback*) proporcionais. |
| **⚔️ Combate Híbrido** | `Melee.bf` / `Projectile.bf` | Lógica de combate corpo-a-corpo (hitboxes giratórias) e projéteis vetoriais com gestão de estados. |
| **🛡️ Dash & Invencibilidade** | `Player.bf` | Mecânicas de movimento avançado com frames de invencibilidade (i-frames) e feedback visual dinâmico. |
| **🧠 IA de Perseguição** | `EnemyStalker.bf` | Inimigos inteligentes que utilizam normalização de vetores para caçar a posição atual do jogador continuamente. |

## 🔩 Arquitetura do Sistema

```mermaid
graph LR
    Main["Program.bf (Entry Point)"]:::process --> Engine["Manivela Engine"]:::core
    
    subgraph Core["Motor Central ⚙️"]
        Engine --> IGame["Interface IGame"]:::interface
        Engine --> SDL["Camada SDL3"]:::lib
    end

    subgraph Game["Endsward Ranch 🤠"]
        IGame --> Ranch["EndswardRanch.bf"]:::logic
        Ranch --> Player["Player"]:::entity
        Ranch --> Enemy["EnemyStalker"]:::entity
        Player --> Combat["Melee / Projectiles"]:::component
        Enemy --> HUD["Healthbar / UI"]:::component
    end
````

## 🔄 Como Girar a Manivela

### Requisitos Técnicos

  * **Beef IDE** (Compilador Beef).
  * Bibliotecas nativas **SDL3** e **SDL3\_image** configuradas no ambiente.

### Configuração e Execução

1.  **Clone** o repositório.
2.  **Ajuste de Caminhos**: No ficheiro `BeefSpace.toml`, certifique-se de que os caminhos para as dependências `SDL3-Beef` e `SDL3_image-Beef` correspondem à sua estrutura de pastas local.
3.  **Build**: Abra o workspace no Beef IDE e compile o projeto como `Manivela_Engine.Program`.

## 📦 Estrutura do Projeto

```text
Manivela-Engine/
├── src/
│   ├── Engine/           # ⚙️ Motor principal e interfaces
│   │   ├── Engine.bf     # Game Loop e SDL Init
│   │   └── IGame.bf      # Contrato de polimorfismo
│   ├── Game/             # 🎮 Implementação da demo Endsward Ranch
│   │   ├── Player.bf     # Movimento e inputs
│   │   ├── EnemyStalker.bf# Comportamento de IA
│   │   └── Melee.bf      # Lógica de ataque físico
│   └── Program.bf        # 🚀 Ponto de entrada ("Girando a Manivela...")
└── assets/               # 🎨 Sprites e recursos visuais
```

## 🤖 Destaques Técnicos

### Física Vetorial e Massa Proporcional

Ao contrário de colisões básicas, o Manivela Engine utiliza um rácio de massa e interpolação linear para gerir a fricção e impactos. Quando ocorre um choque, a força de repulsão é distribuída matematicamente entre as entidades, resultando em movimentos mais realistas e orgânicos.

### Gestão Eficiente de Memória

Aproveitando as capacidades da linguagem Beef, o motor implementa destrutores manuais rigorosos para evitar fugas de memória, especialmente em sistemas dinâmicos como listas de projéteis e componentes de UI.

-----

<p align="center"\>
Desenvolvido com ✨ por <a href="https://www.google.com/search?q=https://github.com/EduLoboM"\>Eduardo Lobo</a\>.
</p\>
