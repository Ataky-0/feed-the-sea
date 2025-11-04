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
As funcionalidades multiplayer e ranking online estão previstas para versões futuras e dependem de backend remoto ainda não implementado.

| ID | Funcionalidades | Objetivo do teste | Método de teste |
| :---- | :---- | :---- | :---- |
| FS01 | Multiplayer online | Não será testada nesta versão |  |
| FS02 | Suporte a mobile | Não será testada nesta versão |  |
| FS03 | Ranking online | Não será testada nesta versão |  |

**Planejamento e Realização dos Testes**

| Caso de teste:  Separar resíduo corretamente | Técnica:  Teste funcional caixa preta | Status:  A executar | Funcionalidade a ser testada: RF01 – Separar resíduos corretamente  |
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

| Caso de teste: 1 Criação de save (sucesso e falha) | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos (armazenamento de progresso)  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Sistema de arquivos simulado ativo (mock de `love.filesystem`). |  | **Entrada:**  `createSave("meu_save")` – Criação de save válido `createSave("save_erro")` com falha simulada de escrita. |  |
|  |  |  |  |
| **Resultado esperado:**  No caso de sucesso: arquivo gerado e metadados corretos (`name`, `created_at`, `last_played`, `file`). No caso de falha: função gera erro controlado `"Erro durante criação de save, arquivo não gerado."` |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Testes automatizados passaram sem falhas. |  | **Passos:**  Rodar lua `test_saves.lua` Verificar saídas do `LuaUnit (OK).` Confirmar comportamento esperado nos dois cenários. |  |
|  |  |  |  |
| **Observações:**  Teste fora do engine LÖVE usando mock do `love.filesystem`. |  |  |  |
|  |  |  |  |

| Caso de teste: 2 Listagem de saves existentes | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com Sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos (armazenamento de progresso)  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Existência de múltiplos saves criados via `createSave`. |  | **Entrada:**  `saves.listSaves()` |  |
|  |  |  |  |
| **Resultado esperado:**  A lista retornada deve conter todos os saves criados (`save1`, `save2`, `save3`) com nomes corretos. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Testes automatizados passaram sem falhas. Retornando (`save1`, `save2`, `save3`)  |  | **Passos:**  Criar 3 saves fictícios chamar `listSaves()` Verificar se os nomes aparecem na lista retornada. |  |
|  |  |  |  |
| **Observações:**  Teste fora do engine LÖVE usando mock do `love.filesystem` |  |  |  |
|  |  |  |  |

| Caso de teste: 3 Deleção de save | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos (gerenciamento de saves) |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Dois saves válidos existentes no sistema de arquivos simulado. |  | **Entrada:**  Chamada da função `deleteSave(meta2.file)` após criação de dois saves (`Save_test1`, `save_test2`). |  |
|  |  |  |  |
| **Resultado esperado:**   O segundo save deve ser removido corretamente. A função `listSaves()` não deve mais retornar o arquivo correspondente a `meta2.file`. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste passou sem falhas. Save deletado não aparece mais na lista final. |  | **Passos:**  Criar dois saves. Executar `deleteSave()` sobre o segundo. Rodar `listSaves()` e confirmar ausência. |  |
|  |  |  |  |
| **Observações:**  Uso de mock de `love.filesystem` para simular remoção de arquivo sem necessidade de disco real. |  |  |  |
|  |  |  |  |

| Caso de teste: 4 Atualização da data de última jogada (last\_played) | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de Recursos (armazenamento e atualização de progresso) |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Um save criado com sucesso e o sistema de arquivos simulado ativo. |  | **Entrada:**  Criação de um save via `createSave("save name")`, espera de 3 segundos, e nova chamada a `saveGame(save, meta.file)`. |  |
|  |  |  |  |
| **Resultado esperado:**  O campo `last_played` do save deve ser atualizado para o horário atual (`getCurrentDate()`).  |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso; `last_played` atualizado corretamente após salvar novamente. |  | **Passos:**  Criar save e registrar metadados iniciais. Esperar 3 segundos. Rodar `saveGame()` e comparar valor de `last_played`. |  |
|  |  |  |  |
| **Observações:**  Teste temporizado — confirma sincronização correta de metadados com o tempo real e integridade dos dados do jogador. |  |  |  |
|  |  |  |  |

| Caso de teste: 5 Criação de save com nome inválido (vazio ou em branco) | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Validação de entrada de nome de save  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Sistema de arquivos simulado ativo. |  | **Entrada:**  Chamadas `createSave("")` e `createSave(" ")`. |  |
|  |  |  |  |
| **Resultado esperado:**  Função deve falhar de forma controlada, lançando erro com a mensagem `"Nome do save não pode estar vazio."`. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Função gerou erro controlado conforme esperado. |  | **Passos:**  Rodar `lua test_saves.lua`. Validar que testes retornam falha controlada. |  |
|  |  |  |  |
| **Observações:**  Validação de entrada assegura integridade dos dados e evita criação de arquivos sem identificação. |  |  |  |
|  |  |  |  |

| Caso de teste: 6 Exibição de Informações Educativas | Técnica:  Teste Funcional (Caixa-Preta) | Status:  A executar | Funcionalidade a ser testada: RF07 – Informações Educativas |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  O jogador deve ter adicionado pelo menos uma espécie (alga ou peixe). O painel de informações deve estar disponível na interface.  |  | **Entrada:**  Jogador clica em uma espécie (ex: sardinha) no ambiente aquático. |  |
|  |  |  |  |
| **Resultado esperado:**  Um painel ou janela deve exibir: Nome da espécie Tipo (produtor, herbívoro, carnívoro) Curiosidade ou informação educativa sobre seu papel ecológico |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  (A preencher após execução) |  | **Passos:**  Adicionar uma espécie ao ambiente. Selecionar a espécie com o cursor. Observar se aparece o painel com as informações corretas. |  |
|  |  |  |  |
| **Observações:**  Validar se todas as espécies possuem textos informativos. Conferir se a interface fecha o painel corretamente após o clique fora.  |  |  |  |
|  |  |  |  |

| Caso de teste: 7 Avaliação de Acessibilidade e Usabilidade Inicial | Técnica:  Teste de Usabilidade | Status:  Executado | Funcionalidade a ser testada: RF08 – Acessibilidade |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Jogador iniciante sem instruções prévias. |  | **Entrada:**  O jogador deve criar um save e tentar adicionar espécies sem auxílio externo. |  |
|  |  |  |  |
| **Resultado esperado:**  Jogador consegue: Criar um save. Adicionar espécies após breve exploração. Entender a lógica básica do jogo sem ajuda. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  A jogadora Gérsika conseguiu executar todas as ações após poucos minutos de exploração. Interface considerada clara e intuitiva. |  | **Passos:**   |  |
|  |  |  |  |
| **Observações:**  Os indicadores (oxigênio, biomassa, herbívoros, carnívoros) poderiam ser mais intuitivos — incluir ícones ou tooltips explicativos em futuras versões. |  |  |  |
|  |  |  |  |

| Caso de teste: 8 Efeito da Poluição sobre os Recursos | Técnica:  Teste Funcional (Caixa-Preta) | Status:  A executar | Funcionalidade a ser testada: RF – Poluição interfere no oxigênio e alimento |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Ambiente com indicadores de poluição/higiene ativos. Sistema de recursos (oxigênio e alimento) em valores estáveis.  |  | **Entrada:**  Aumentar intencionalmente a poluição (ex.: inserir lixo ou evento de vazamento). Aguardar 1 minuto de simulação.  |  |
|  |  |  |  |
| **Resultado esperado:**  Valores de oxigênio e alimento diminuem progressivamente. Mensagens ou indicadores visuais refletem o desequilíbrio ambiental. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  (A preencher após execução) |  | **Passos:**  Criar save limpo e estável. Aumentar poluição manualmente (ou simular evento). Observar valores de oxigênio e alimento antes e depois. |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

**Testes Exploratórios**

| Teste 1: Criação e carregamento de save |  | Data: 03/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Criar um novo save (“teste\_1”) e adicionar uma alga e uma sardinha. Salvar o jogo e retornar ao menu principal. Recarregar o save “teste\_1”. |  |
|  |  |  |  |
| **Objetivo da exploração:**  Verificar se o sistema de save está armazenando corretamente as informações de progresso (espécies adicionadas, recursos e ambiente). |  |  |  |
|  |  |  |  |
| **Resultado observado:** O save foi carregado com as espécies e valores de oxigênio/alimento preservados corretamente. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |

| Teste 2: Interação entre Alga e Sardinha |  | Data: 03/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Adicionadas 3 **algas** e 4 **sardinhas**. Acompanhado o comportamento dos indicadores por 2 minutos. Observado o impacto sobre oxigênio, biomassa e herbívoros. |  |
|  |  |  |  |
| **Objetivo da exploração:**  Observar se a relação entre as espécies afeta corretamente os recursos de oxigênio, biomassa e alimentação. |  |  |  |
|  |  |  |  |
| **Resultado observado:** Início: (Apos à adição) Oxi: 6.6   Bio: 2.5 Herb: 1.1  Carn: 0.0 Após 2 minutos: Oxi: 6.6   Bio: 3.9 Herb: 1.1  Carn: 0.0 O sistema manteve o oxigênio estável e aumentou levemente a biomassa, indicando equilíbrio entre produção e consumo. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |

| Teste 3: Primeira experiência de jogo para novo jogador |  | Data: 03/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gérsika Linhares \- novo jogador (não familiarizado com o jogo) |  | **Ação realizada:**  Iniciou o jogo sem instruções prévias. Criou o save com seu nome Inicialmente tentou adicionar peixes, depois percebeu a necessidade de adicionar algas primeiro e realizou a sequência correta (alga → peixe). |  |
|  |  |  |  |
| **Objetivo da exploração:**  Avaliar se a interface e a lógica básica do jogo são compreensíveis para um novo jogador sem explicações diretas. |  |  |  |
|  |  |  |  |
| **Resultado observado:** A interface foi considerada fácil de entender e intuitiva. A jogadora não apresentou dificuldade para navegar ou compreender as ações básicas (criar save, adicionar espécies, etc.). |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |
| **Observações:** Embora a interface geral seja clara, os indicadores de recursos (oxigênio, biomassa, herbívoros, carnívoros) podem não ser totalmente intuitivos para novos jogadores  |  |  |  |

| Teste 4: Comportamento inesperado ao criar save rapidamente |  | Data: 03/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Iniciou o jogo e criou rapidamente um save com o nome **“ge”**. Adicionou uma **alga** e uma **sardinha**. Ao visualizar o ambiente, além da alga e da sardinha esperadas, apareceu um **terceiro elemento anômalo** — semelhante a uma parte da alga, mas com **tamanho próximo ao da sardinha** e comportamento estranho (movendo-se e piscando/desaparecendo). |  |
|  |  |  |  |
| **Objetivo da exploração:**  Testar a estabilidade e integridade do sistema de saves durante criação e carregamento rápidos. |  |  |  |
|  |  |  |  |
| **Resultado observado:** O save apresentou um objeto visual incorreto e, após sair e tentar recarregar, não pôde ser carregado. O arquivo JSON mostrava uma referência incorreta de planta dentro da lista de peixes. Após remover manualmente `"plant001": 1` de `"fish"`, o save pôde ser reaberto normalmente. |  | **Anomalias/Bugs:** Ocorreu erro de serialização dos dados, incluindo um identificador de planta no campo de peixes.O problema não pôde ser reproduzido em tentativas posteriores, mesmo repetindo o processo de criação rápida. |  |
|  |  |  |  |
| **Observações:** Pode se tratar de um erro intermitente de inicialização, possivelmente quando o jogador cria o save antes do carregamento completo do ambiente.  |  |  |  |

| Teste 5: Persistência após reinício do jogo |  | Data: 04/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Criado um novo save (“teste\_persistência”). Adicionadas 2 algas e 2 sardinhas. Observados os indicadores por 1 minuto. O jogo foi fechado completamente e reaberto. O save foi recarregado e os indicadores comparados com o estado anterior. |  |
|  |  |  |  |
| **Objetivo da exploração:**  Verificar se os dados do save permanecem consistentes após reiniciar o jogo (incluindo espécies, posições e valores de oxigênio, biomassa). |  |  |  |
|  |  |  |  |
| **Resultado observado:** O save foi carregado corretamente após reinício. Espécies e posições preservadas, indicadores mantiveram os valores registrados antes do fechamento. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |
| **Observações:**  |  |  |  |

**Conclusão**  
Este plano de testes assegura que as principais funcionalidades do jogo *Feed The Sea* serão validadas tanto manualmente quanto por meio de testes automatizados com LuaUnit. A estratégia cobre desde a lógica de recursos até a experiência do jogador, garantindo estabilidade, clareza e aderências aos objetivos do projeto.