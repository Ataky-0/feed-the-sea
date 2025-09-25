**Plano de Testes – *Feed The Sea***  
Este documento descreve como será realizada a estratégia de testes do projeto *Feed The Sea*. O objetivo é definir os tipos de testes, o escopo, os casos de teste e as ferramentas utilizadas para garantir a qualidade do software.

**Objetivo dos teste**

* Validar que as funcionalidades descritas nos requisitos foram corretamente implementadas.  
* Garantir que a experiência de jogo seja estável, intuitiva e coerente com os objetivos de sustentabilidade.  
* Detectar falhas funcionais, lógicas e de interface antes da entrega.  
* Assegurar que os recursos críticos (oxigênio, alimento, poluição) se comportem conforme as regras definidas.

**Abordagens de testes utilizados**

| Testes Funcionais (caixa-preta) | Validar interações do jogador (ex.: limpar ambiente, adicionar espécies, expandir ecossistema). |
| :---- | :---- |
| **Testes Unitários (caixa-branca)** | Utilizar a biblioteca **LuaUnit** para verificar a corretude de funções centrais do jogo (ex.: cálculo de oxigênio, pontuação, eventos aleatórios). |
| **Testes de Usabilidade** | Avaliação manual para garantir clareza na interface e facilidade de aprendizado. |
| **Testes de Performance (exploratórios)** | Verificar tempo de resposta e fluidez do jogo em diferentes dispositivos. |

**Escopo dos testes**  
**Dentro do escopo**

| ID | Funcionalidades | Objetivo do teste | Método de teste |
| :---- | :---- | :---- | :---- |
| RF01 | Limpeza do ambiente | Validar que o jogador consegue remover resíduos e plantas mortas. | Funcional (Caixa-preta) |
| RF02 | Variedade de espécies | confirmar o desbloqueio de novas espécies ao progredir. | Unitário (LuanUnit) \+ Funcional |
| RF03 | Gerenciar vida marinha | Verificar se animais e plantas são adicionados corretamente e influenciam recursos. | Unitário \+ Funcional |
| RF04 | Expansão do ambiente | Testar se a expansão libera novas áreas e espécies. | Funcional |
| RF05 | Disponibilidade de recursos | Validar geração e consumo de oxigênio e alimento. | Unitário (LuaUnit) |
| RF06 | Eventos aleatórios | Garantir que eventos impactam diretamente o ambiente. | Funcional  |
| RF07 | Informações educativas | Conferir se as informações sobre espécies são exibidas corretamente. | Funcional |
| RF08 | Acessibilidade | Avaliar simplicidade e clareza da interface | Usabilidade |
| RF09 | Liberdade criativa | Verificar ausência de caminhos fixos obrigatórios  | Funcional |

**Fora do Escopo**

| ID | Funcionalidades | Objetivo do teste | Método de teste |
| :---- | :---- | :---- | :---- |
| FS01 | Multiplayer online | Não será testada nesta versão |  |
| FS02 | Suporte a mobile | Não será testada nesta versão |  |
| FS03 | Ranking online | Não será testada nesta versão |  |

**Planejamento e Realização dos Testes**

| Caso de teste:  Separar resíduo corretamente | Técnica:  Teste funcional caixa preta | Status:  A executar | Funcionalidade a ser testada:  RF01 – Separar resíduos corretamente  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  O jogador deve estar em uma fase ativa. O sistema deve exibir lixeiras e resíduos. |  | **Entrada:** Jogador arrasta um papel para a lixeira azul. |  |
|  |  |  |  |
| **Resultado esperado:**  O sistema valida corretamente.O jogador recebe pontos.Mensagem de acerto exibida.  |  |  |  |
|  |  |  |  |
| **Resultado obtido:**   (A preencher durante a execução) |  | **Passos:**  Iniciar a fase 1\. Selecionar resíduo (papel). Levar até a lixeira azul. Confirmar feedback do sistema. |  |
|  |  |  |  |
| **Observações:**  |  |  |  |
|  |  |  |  |

**Conclusão**  
Este plano de testes assegura que as principais funcionalidades do jogo *Feed The Sea* serão validadas tanto manualmente quanto por meio de testes automatizados com LuaUnit. A estratégia cobre desde a lógica de recursos até a experiência do jogador, garantindo estabilidade, clareza e aderências aos objetivos do projeto.