# Plano de Testes – *Feed The Sea*

Este documento descreve como será realizada a estratégia de testes do projeto *Feed The Sea*. O objetivo é definir os tipos de testes, o escopo, os casos de teste e as ferramentas utilizadas para garantir a qualidade do software.

## Objetivo dos testes

* Validar que as funcionalidades descritas nos requisitos foram corretamente implementadas.  
* Garantir que a experiência de jogo seja estável, intuitiva e coerente com os objetivos de sustentabilidade.  
* Detectar falhas funcionais, lógicas e de interface antes da entrega.  
* Assegurar que os recursos críticos (oxigênio, alimento, poluição) se comportem conforme as regras definidas.

## Abordagens de testes utilizados

| Testes Funcionais (caixa-preta) | Validar interações do jogador (ex.: limpar ambiente, adicionar espécies, expandir ecossistema). |
| :---- | :---- |
| **Testes Unitários (caixa-branca)** | Utilizar a biblioteca **LuaUnit** para verificar a corretude de funções centrais do jogo (ex.: cálculo de oxigênio, pontuação, eventos aleatórios). |
| **Testes de Usabilidade** | Avaliação manual para garantir clareza na interface e facilidade de aprendizado. |
| **Testes de Performance (exploratórios)** | Verificar tempo de resposta e fluidez do jogo em diferentes dispositivos. |

## 1- Escopo dos testes

**Dentro do escopo**

| ID | Funcionalidades | Objetivo do teste | Método de teste |
| :---- | :---- | :---- | :---- |
| RF01 | Limpeza do ambiente | Validar que o jogador consegue remover resíduos e plantas mortas. | Funcional (Caixa-preta) |
| RF02 | Variedade de espécies | confirmar o desbloqueio de novas espécies ao progredir. | Unitário (LuaUnit) \+ Funcional |
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

## 2- Casos de Teste Funcionais e Unitários

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
| **Observações:**  Teste realizado fora da engine LÖVE usando mock do `love.filesystem`. |  |  |  |
|  |  |  |  |

| Caso de teste: 2 Listagem de saves existentes | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos (armazenamento de progresso)  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Existência de múltiplos saves criados via `createSave`. |  | **Entrada:**  `saves.listSaves()` |  |
|  |  |  |  |
| **Resultado esperado:**  A lista retornada deve conter todos os saves criados (`save1`, `save2`, `save3`) com nomes corretos. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Testes automatizados passaram sem falhas. Retornando (`save1`, `save2`, `save3`)  |  | **Passos:**  Criar 3 saves fictícios Chamar listSaves() Verificar se os nomes aparecem na lista retornada. |  |
|  |  |  |  |
| **Observações:**  Teste realizado fora da engine LÖVE usando mock do `love.filesystem` |  |  |  |
|  |  |  |  |

| Caso de teste: 3 Deleção de save | Técnica:  Teste unitário (caixa branca) – LuaUnit | Status:  Executado com sucesso | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos (gerenciamento de saves) |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Dois saves válidos existentes no sistema de arquivos simulados. |  | **Entrada:**  Chamada da função `deleteSave(meta2.file)` após criação de dois saves (`Save_test1`, `save_test2`). |  |
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

| Caso de teste: 6 Exibição de Informações Educativas | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data:  12/12/2025 | Funcionalidade a ser testada: RF07 – Informações Educativas |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  O jogador deve ter adicionado pelo menos uma espécie (alga ou peixe). O botão de "Informações" deve estar disponível na interface. A espécie selecionada deve ter descrição e curiosidade cadastradas.  |  | **Entrada:**  O jogador deve clicar no “i” de informações ao lado da espécie desejada. O tooltip é ativado. |  |
|  |  |  |  |
| **Resultado esperado:**  O tooltip deve ser ativado ao clicar no “i” de informações. O painel exibido abre a descrição da espécie. Ao clicar no mesmo botão “i” o tooltip  é fechado. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso |  | **Passos:**  Criar um save. Abrir o menu clicando no botão de “+”. Clicar no “i” de informações sobre qualquer espécie. |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

| Caso de teste: 7 Avaliação de Acessibilidade e Usabilidade Inicial | Técnica:  Teste de Usabilidade | Status:  Executado | Funcionalidade a ser testada: RF08 – Acessibilidade |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Jogador iniciante sem instruções prévias. |  | **Entrada:**  O jogador deve criar um save e tentar adicionar espécies sem auxílio externo. |  |
|  |  |  |  |
| **Resultado esperado:**  O jogador deve conseguir: Criar um save. Adicionar espécies após breve exploração. Entender a lógica básica do jogo sem ajuda. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  A jogadora Gérsika conseguiu executar todas as ações após poucos minutos de exploração. Interface considerada clara e intuitiva. |  | **Passos:**   |  |
|  |  |  |  |
| **Observações:**  Os indicadores (oxigênio, biomassa, herbívoros, carnívoros) poderiam ser mais intuitivos — incluir ícones ou tooltips explicativos em futuras versões. |  |  |  |
|  |  |  |  |

| Caso de teste: 8 Efeito da Poluição sobre a Produção e o Multiplicador | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data:  12/12/2025 | Funcionalidade a ser testada: RF06 – Eventos Aleatórios / Poluição influencia recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Ambiente limpo, sem resíduos visíveis. Matéria Orgânica produzindo em **x1.00**. Algas suficientes para atingir o cap (ex.: 4 algas \= 5.31 mg C). Nenhum lixo visível no ambiente. Timer de eventos funcionando (spawn de lixo a cada 1m30s quando crítico).  |  | **Entrada:**  Jogador aguarda o surgimento natural de lixo (evento automático ≈ 1m30s). Assim que aparecer **QUALQUER** resíduo: observar redução imediata do multiplicador da Matéria Orgânica. Jogador remove o lixo **clicando sobre ele**. Observar se o multiplicador volta a subir imediatamente.  |  |
|  |  |  |  |
| **Resultado esperado:**  Ao surgir o primeiro lixo, um resíduo aparece e o multiplicador **reduz** (ex.: **x1.00 → x0.90**). A produção de Matéria Orgânica fica mais lenta. Ao **clicar no lixo**, ele desaparece imediatamente e o multiplicador **sobe de volta** (ex.: **x0.90 → x1.00**). Com o ambiente totalmente limpo, o multiplicador retorna para **x1.00** e a produção volta ao cap normal. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso |  | **Passos:**  Criar um novo save e garantir que o ambiente esteja limpo. Confirmar produção normal da Matéria Orgânica (x1.00). **Aguardar \~1m30s** até o primeiro resíduo surgir. Observar a queda do multiplicador (ex.: x0.90). **Clicar imediatamente no resíduo para removê-lo.** Verificar que o multiplicador sobe novamente até x1.00. Confirmar que a produção volta ao ritmo total. |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

| Caso de teste: 9 Produção de oxigênio por algas | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 26/11/2025 | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Haver pelo menos 1 alga no ambiente. Indicador de oxigênio ativo. |  | **Entrada:**  Jogador adiciona 1 alga.  |  |
|  |  |  |  |
| **Resultado esperado:**  O oxigênio aumenta instantaneamente. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso |  | **Passos:**  Iniciar o jogo. Adicionar alga. Observar o indicador imediatamente. |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

| Caso de teste: 10 Impedir criação de peixe sem alga | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado Data: 26/11/2025 | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Não haver algas no ambiente. |  | **Entrada:**  O jogador tenta adicionar um peixe.  |  |
|  |  |  |  |
| **Resultado esperado:**  Sistema impede criação e exibe aviso. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso Mensagem de erro (Recursos insuficientes para invocar “Tilápia ou sardinha”) |  | **Passos:**  Abrir o jogo Não criar algas Tentar criar algum peixe. |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

| Caso de teste: 11 Arrastar alga altera posição | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado Data: 26/11/2025 | Funcionalidade a ser testada: RF08 – Acessibilidade / Interações |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Haver alga no cenário. |  | **Entrada:**  O jogador arrasta a alga.  |  |
|  |  |  |  |
| **Resultado esperado:**  Alga muda de posição e permanece funcional. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso |  | **Passos:**  Criar alga Clicar e arrastar Soltar em outra posição |  |
|  |  |  |  |
| **Observações:**   |  |  |  |
|  |  |  |  |

| Caso de teste: 12 Impedir arrastar para fora da área | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado Data: 26/11/2025 | Funcionalidade a ser testada: RF08 – Acessibilidade / Interações |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Mapa totalmente carregado. |  | **Entrada:**  O jogador tenta arrastar a alga para fora do mapa. |  |
|  |  |  |  |
| **Resultado esperado:**  Alga não sai da área permitida. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste com falha |  | **Passos:**  Criar alga Tentar arrastar para fora do mapa. |  |
|  |  |  |  |
| **Observações:**  É possível arrastar a alga para fora do mapa |  |  |  |
|  |  |  |  |

| Caso de teste: 13 Seleção precisa de espécies (hitbox) | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado Data: 27/11/2025 | Funcionalidade a ser testada: RF08 – Acessibilidade / Interações |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Espécies posicionadas próximas umas das outras. |  | **Entrada:**  Clicar individualmente em cada uma das algas, |  |
|  |  |  |  |
| **Resultado esperado:**  A espécie correta é selecionada. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso |  | **Passos:**  Criar 3 algas próximas. Clicar em cada alga separadamente  Tentar arrastar a alga selecionada |  |
|  |  |  |  |
| **Observações:**  O hitbox funciona com certa preferência por ordem, a alga que foi criada primeiro tem mais prioridade se outra estiver sobre ela. |  |  |  |
|  |  |  |  |

| Caso de teste: 14 Invocação sem Seleção Corrompe o Save | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado – Falha Crítica Encontrada Data: 12/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar Vida Marinha RF05 – Disponibilidade de Recursos RNF4 – Confiabilidade do Save |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Um save já criado. Pelo menos 1 entidade adicionada ao mapa (ex.: uma alga). Painel de invocação acessível. Nenhuma alga selecionada na aba “Algas”. *O bug **não ocorre** se o jogador tentar “Invocar” logo após criar o save. Ele só acontece **depois** que o jogador já adicionou alguma entidade.*  |  | **Entrada:**  Criar um save. Adicionar 1 alga ao mapa. Abrir novamente o painel de invocação. Invocar um peixe (Sardinha/Tilápia). Ir para a aba “Algas”. Clicar em **“Invocar”** sem selecionar nada. |  |
|  |  |  |  |
| **Resultado esperado:**  O jogo deveria bloquear a ação. Mensagem esperada: **“Selecione uma entidade antes de invocar.”**O save não deveria ser alterado.  |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Tela azul (erro de execução). Ao reabrir o jogo e carregar o save: O mapa aparece **vazio**. Todas as entidades foram perdidas. O save foi **corrompido**. |  | **Passos:**  Criar save. Adicionar alga. Invocar peixe. Ir para aba “Algas”. Clicar em “Invocar” sem escolher nada. Tela azul. Fechar e reabrir o jogo. O save volta vazio. |  |
|  |  |  |  |
| **Observações:**  O jogo está permitindo `Invocar` com seleção nula. Isso causa erro e grava um save inválido. Impacto: **alto** — perda total de progresso. Este caso deve virar **Teste de Regressão** após correção.  |  |  |  |
|  |  |  |  |

| Caso de teste: 15 Carregamento de entidades com arquivo inexistente | Técnica:  Teste Unitário (Caixa-Branca) – LuaUnit | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF02 – Variedade de espécies RF03 – Gerenciar vida marinha RF07 – Informações educativas |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Sistema de arquivos simulado ativo (mock de `love.filesystem`). Arquivo `data/entities.json` **não existe** no sistema.  |  | **Entrada:**  Chamada da função: `entities.loadEntities()` |  |
|  |  |  |  |
| **Resultado esperado:**  A função deve falhar de forma controlada. Um erro deve ser lançado informando a impossibilidade de carregar o arquivo `entities.json`. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso. O sistema lançou erro conforme esperado ao tentar carregar um arquivo inexistente. |  | **Passos:**  Remover `data/entities.json` do mock de filesystem. Executar `entities.loadEntities()`. Verificar se ocorre erro controlado.  |  |
|  |  |  |  |
| **Observações:**  Este teste garante robustez do sistema contra ausência de arquivos essenciais e evita falhas silenciosas durante a inicialização do jogo. |  |  |  |
|  |  |  |  |

| Caso de teste: 16 Carregamento de entidades com JSON inválido | Técnica:  Teste Unitário (Caixa-Branca) – LuaUnit | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF02 – Variedade de espécies RF03 – Gerenciar vida marinha RF07 – Informações educativas |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Sistema de arquivos simulado ativo. Arquivo `data/entities.json` existe, porém contém JSON malformado. |  | **Entrada:**  Conteúdo inválido no arquivo: { INVALID JSON } Execução de: `entities.loadEntities()` |  |
|  |  |  |  |
| **Resultado esperado:**  A função deve falhar ao tentar decodificar o JSON. O erro deve ser propagado e impedir o carregamento das entidades. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso. Erro lançado corretamente durante a tentativa de decodificação do JSON inválido. |  | **Passos:**  Inserir conteúdo inválido no mock de `entities.json`. Executar `entities.loadEntities()`. Verificar falha controlada.  |  |
|  |  |  |  |
| **Observações:**  Este teste evita que dados corrompidos sejam carregados, garantindo integridade das entidades utilizadas no jogo. |  |  |  |
|  |  |  |  |

| Caso de teste: 17 Carregamento de entidades com listas vazias | Técnica:  Teste Unitário (Caixa-Branca) – LuaUnit | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF02 – Variedade de espécies RF03 – Gerenciar vida marinha |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Sistema de arquivos simulado ativo. Arquivo `entities.json` válido, porém sem entidades cadastradas.  |  | **Entrada:**  Arquivo `entities.json` contendo: {   `"fish": {},   "plant": {}` } Execução de: `entities.getFishList() entities.getPlantList()`  |  |
|  |  |  |  |
| **Resultado esperado:**  As funções devem retornar listas vazias. O sistema não deve gerar erro ou crash. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso. Listas vazias retornadas corretamente. |  | **Passos:**  Substituir conteúdo do mock `entities.json` por listas vazias. Executar `getFishList()` e `getPlantList()`. Verificar tamanho das listas retornadas. |  |
|  |  |  |  |
| **Observações:**  Este teste cobre cenários limite e garante estabilidade do sistema mesmo sem entidades disponíveis no jogo. |  |  |  |
|  |  |  |  |

| Caso de teste: 18 Equilíbrio de recursos com grande quantidade de peixes herbívoros (sardinhas) | Técnica:  Teste Funcional (Caixa-Preta) \+ Teste de Limite (Boundary Testing) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar vida marinhaRF05 – Disponibilidade de recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Save criado com sucesso. Indicadores iniciando nos valores padrão do jogo. Ambiente sem poluição visível. Capacidade máxima dos indicadores habilitada pelo sistema.  |  | **Entrada:**   Adição de 4 algas ao ambiente. Adição de aproximadamente 19 sardinhas (peixes herbívoros). Nenhum peixe carnívoro adicionado.  |  |
|  |  |  |  |
| **Resultado esperado:**  O oxigênio deve diminuir proporcionalmente ao consumo das sardinhas. A dieta herbívora deve apresentar valor positivo coerente. A dieta carnívora deve permanecer em **0.00 mg C**, pois não há carnívoros.A matéria orgânica deve aumentar de forma controlada, respeitando o multiplicador. O sistema não deve ultrapassar limites máximos nem gerar valores negativos. O jogo deve permanecer estável, sem travamentos ou inconsistências visuais. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Oxigênio estabilizado em **2.35 mg O₂**. Dieta herbívora em **0.10 mg C**, compatível com a quantidade de sardinhas. Dieta carnívora permaneceu em **0.00 mg C**, conforme esperado. Matéria orgânica em **0.45 mg C (x1.00)**. Nenhum crash, erro visual ou comportamento inesperado observado. |  | **Passos:**  Criar um novo save.Adicionar quatro algas ao ambiente. Adicionar múltiplas sardinhas até atingir o limite prático do cenário. Observar os indicadores de oxigênio, matéria orgânica e dietas. Verificar estabilidade geral do jogo. |  |
|  |  |  |  |
| **Observações:**  Este teste valida o comportamento do sistema em cenário de alta densidade de peixes herbívoros. Confirma que o balanceamento ecológico funciona corretamente sem a presença de predadores. Demonstra estabilidade do jogo em condições próximas ao limite operacional. |  |  |  |
|  |  |  |  |

| Caso de teste: 19 Equilíbrio de recursos com peixes herbívoros de médio porte (Tilápias) | Técnica:  Teste Funcional (Caixa-Preta) \+ Teste de Carga Moderada | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar vida marinhaRF05 – Disponibilidade de recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Save criado com sucesso. Indicadores iniciando nos valores padrão do jogo. Ambiente sem poluição ativa. Capacidade padrão dos indicadores habilitada. |  | **Entrada:**  Adição de **4 algas** ao ambiente. Adição de **9 tilápias** (peixes herbívoros de porte médio). Nenhum peixe carnívoro ou cardume adicionado. |  |
|  |  |  |  |
| **Resultado esperado:**  O consumo de oxigênio deve ser **mais elevado** do que no cenário com sardinhas, devido ao maior porte das tilápias. A dieta herbívora deve apresentar valor **baixo, porém positivo**, refletindo consumo controlado. A dieta carnívora deve permanecer em **0.00 mg C**. A matéria orgânica deve aumentar de forma gradual, respeitando o multiplicador. O sistema não deve gerar valores negativos nem ultrapassar limites máximos. O jogo deve permanecer estável. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Oxigênio estabilizado em **3.15 mg O₂**. Dieta herbívora observada em **0.02 mg C**, valor compatível com a configuração. Dieta carnívora permaneceu em **0.00 mg C**, conforme esperado.Matéria orgânica em **0.54 mg C (x1.00)**. Nenhum erro, travamento ou comportamento inesperado observado. |  | **Passos:**  Criar um novo save. Adicionar quatro algas ao ambiente. Adicionar nove tilápias. Aguardar estabilização dos indicadores. Observar valores de oxigênio, matéria orgânica e dietas. |  |
|  |  |  |  |
| **Observações:**  Este teste evidencia a diferença de impacto ecológico entre peixes herbívoros de pequeno porte (sardinhas) e médio porte (tilápias). O sistema respondeu de forma coerente ao aumento do consumo de oxigênio.O balanceamento ecológico permaneceu estável, validando a progressão de dificuldade.  |  |  |  |
|  |  |  |  |

| Caso de teste: 20 Interação entre produtores, herbívoros (cardume) e carnívoros (cavala) | Técnica:  Teste Funcional (Caixa-Preta) \+ Teste de Regras de Jogo | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar vida marinhaRF05 – Disponibilidade de recursosRF09 – Liberdade criativa (com restrições ecológicas)  |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Save criado com sucesso. Indicadores iniciando nos valores padrão. Ambiente sem poluição.Capacidade padrão dos indicadores ativa. Sistema de validação ecológica ativo.  |  | **Entrada:**  Adição de **4 algas**. Adição de **5 cardumes de sardinhas**. Adição de **3 cavalas** (peixes carnívoros). Tentativa de adicionar **cavala sem cardume** (ação negada pelo sistema). |  |
|  |  |  |  |
| **Resultado esperado:**  O sistema **não deve permitir** a criação de peixes carnívoros sem a existência de uma fonte de alimento animal (cardume). A dieta herbívora deve apresentar valor positivo, refletindo o consumo das algas pelos cardumes. A dieta carnívora deve apresentar valor positivo, refletindo o consumo dos cardumes pelas cavalas. O oxigênio deve sofrer **queda significativa**, devido ao alto consumo combinado. A matéria orgânica deve permanecer dentro dos limites e respeitar o multiplicador. O jogo deve permanecer estável, sem erros ou travamentos. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Oxigênio reduzido para **0.41 mg O₂**, indicando alto consumo combinado. Dieta herbívora registrada em **0.25 mg C**. Dieta carnívora registrada em **0.85 mg C**. Matéria orgânica em **0.30 mg C (x1.00)**. O sistema **impediu corretamente** a criação de cavala sem cardume. Nenhum erro, travamento ou inconsistência observada. |  | **Passos:**  Criar um novo save. Adicionar quatro algas ao ambiente. Adicionar cinco cardumes de sardinhas. Adicionar três cavalas. Observar indicadores após estabilização. Tentar adicionar cavala sem cardume presente. Verificar bloqueio da ação. |  |
|  |  |  |  |
| **Observações:**  Este teste valida explicitamente a cadeia alimentar do jogo. A obrigatoriedade do cardume para criação de carnívoros reforça o conceito educacional do ecossistema.O sistema não permite configurações ecologicamente inválidas, mesmo dando liberdade ao jogador. Excelente exemplo para demonstração didática durante a apresentação. |  |  |  |
|  |  |  |  |

| Caso de teste: 21 Produção elevada de oxigênio pelo Capim-marinho | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos RF03 – Gerenciar vida marinha |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Save recém-criado. Ambiente sem plantas. Indicadores de oxigênio visíveis.  |  | **Entrada:**  Jogador adiciona 1 unidade de **Capim-marinho**. |  |
|  |  |  |  |
| **Resultado esperado:**  O oxigênio aumenta significativamente, conforme descrito na entidade (**\+1.80**). O aumento é maior do que o observado com a alga comum. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Oxigênio aumentou conforme esperado. |  | **Passos:**  Criar um novo save. Abrir o menu de plantas. Selecionar Capim-marinho. Invocar no ambiente. Observar o indicador de oxigênio. |  |
|  |  |  |  |
| **Observações:**  Confirma que o Capim-marinho é mais eficiente na oxigenação do ambiente. |  |  |  |
|  |  |  |  |

| Caso de teste: 22 Capim-marinho sustenta herbívoros com maior custo ecológico | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar vida marinha RF05 – Disponibilidade de recursos |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Ambiente com Capim-marinho invocado. Indicadores de Dieta Herbívora e Matéria Orgânica ativos. |  | **Entrada:**  Jogador adiciona 1 Capim-marinho. Em seguida, adiciona sardinhas ou cardume.  |  |
|  |  |  |  |
| **Resultado esperado:**  A Dieta Herbívora aumenta conforme o valor descrito (**0.90**). A Matéria Orgânica sofre uma redução maior (**custo 4.50**). O sistema permanece estável, sem travamentos ou valores inválidos. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Indicadores se comportaram conforme esperado. |  | **Passos:**  Criar save. Invocar Capim-marinho. Observar Dieta Herbívora e Matéria Orgânica. Invocar sardinhas ou cardume. Acompanhar indicadores por alguns segundos. |  |
|  |  |  |  |
| **Observações:**  Valida o equilíbrio entre alto benefício ecológico e alto custo ambiental. |  |  |  |
|  |  |  |  |

| Caso de teste: 23 Produção de Matéria Orgânica e Oxigênio com Peixe-Palhaço e Capim-Marinho | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF05 – Disponibilidade de recursos RF03 – Gerenciar vida marinha RF02 – Variedade de espécies |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Save criado e ambiente limpo. Indicadores de Oxigênio, Matéria Orgânica, Dieta Herbívora e Dieta Carnívora visíveis. Capim-marinho disponível no menu de plantas. Peixe-palhaço disponível no menu de peixes. |  | **Entrada:**  Adição de aproximadamente 22 peixes-palhaço. Adição de 2 capins-marinhos. Aguardar cerca de 1 minuto e 30 segundos sem intervenções. |  |
|  |  |  |  |
| **Resultado esperado:**  O oxigênio deve permanecer estável ou aumentar levemente, devido à alta produção do capim-marinho. A Matéria Orgânica deve aumentar progressivamente até atingir o valor máximo permitido. A Dieta Herbívora deve permanecer baixa, compatível com o consumo reduzido do peixe-palhaço. A Dieta Carnívora deve permanecer zerada. O jogo deve permanecer estável, sem quedas de FPS ou erros visuais, mesmo com alta quantidade de peixes. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Oxigênio permaneceu estável em aproximadamente **3.10 mg O₂**. Matéria Orgânica aumentou de **1.44 mg C** para **4.52 mg C (Máximo)** após \~1m30. Dieta Herbívora manteve valor baixo (**0.04 mg C**). Dieta Carnívora permaneceu em **0.00 mg C**. Nenhum bug, travamento ou comportamento anômalo foi observado. |  | **Passos:**  Criar um novo save. Adicionar 2 capins-marinhos ao ambiente. Adicionar aproximadamente 22 peixes-palhaço. Observar os indicadores imediatamente após a criação. Aguardar cerca de 1 minuto e 30 segundos. Comparar os valores iniciais e finais dos indicadores. |  |
|  |  |  |  |
| **Observações:**  O teste demonstra que o peixe-palhaço é adequado para cenários de alta densidade, pois apresenta baixo impacto negativo nos recursos.O capim-marinho se mostrou eficiente para sustentar grandes populações de peixes de pequeno porte. O equilíbrio do ecossistema foi mantido mesmo em cenário próximo ao limite visual de entidades. |  |  |  |
|  |  |  |  |

| Caso de teste: 24 Ajuste da interface ao redimensionar a janela (LoadGame) | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF08 – Acessibilidade RNF02 – Usabilidade RNF03 – Responsividade da Interface |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Jogo iniciado normalmente. Pelo menos um save criado. Cena **LoadGame** acessível. |  | **Entrada:**  O jogador acessa a cena LoadGame. Redimensiona a janela para um tamanho menor que o padrão. Em seguida, redimensiona para um tamanho maior que o padrão. |  |
|  |  |  |  |
| **Resultado esperado:**  A interface se reajusta corretamente. Botões, textos e listas permanecem visíveis. Nenhum elemento da UI fica fora da tela. Não ocorre quebra visual nem sobreposição indevida. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  A interface se reajusta corretamente. Botões, textos e listas permanecem visíveis.Nenhum elemento da UI fica fora da tela. Não ocorre quebra visual nem sobreposição indevida.  |  | **Passos:**  Iniciar o jogo. Acessar o menu **LoadGame**. Diminuir o tamanho da janela. Observar o layout da UI. Aumentar o tamanho da janela novamente. Confirmar estabilidade visual. |  |
|  |  |  |  |
| **Observações:**  Este teste valida a correção aplicada no layout da cena LoadGame, garantindo melhor experiência em diferentes resoluções. |  |  |  |
|  |  |  |  |

| Caso de teste: 25 Interação com UI do LoadGame após redimensionamento | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 14/12/2025 | Funcionalidade a ser testada: RF01 – Navegação RF08 – Acessibilidade RNF02 – Usabilidade |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Cena **LoadGame** aberta. Interface já redimensionada para um tamanho não padrão. |  | **Entrada:**  O jogador tenta: Selecionar um save. Clicar em botões (Carregar / Voltar). Navegar normalmente pela UI. |  |
|  |  |  |  |
| **Resultado esperado:**  Todos os botões continuam clicáveis. A seleção de saves funciona corretamente. Nenhuma área “morta” de clique surge após o resize.  |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Todas as interações funcionaram normalmente após o redimensionamento.Não foram detectadas falhas de clique ou navegação.  |  | **Passos:**  Redimensionar a janela na cena LoadGame. Selecionar um save da lista. Clicar no botão de carregar. Retornar ao menu anterior. |  |
|  |  |  |  |
| **Observações:**  Este teste garante que o redimensionamento não afeta a lógica de interação da UI. |  |  |  |
|  |  |  |  |

## 3- Testes de Regressão

Os testes de regressão têm como objetivo garantir que correções implementadas no código não reintroduzam falhas previamente identificadas e que funcionalidades corrigidas continuem funcionando após modificações no sistema.

| Caso de teste: 12R Impedir arrastar para fora da área | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado — Falha identificada (corrigida posteriormente no teste 12R) Data: 08/12/2025 | Funcionalidade a ser testada: RF08 – Acessibilidade / Interações |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Ambiente carregado. Ao menos uma planta no cenário |  | **Entrada:**  O jogador tenta arrastar a alga para fora do mapa. |  |
|  |  |  |  |
| **Resultado esperado:**  A planta não permanece fora da área permitida e retorna automaticamente para uma posição válida |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste corrigido com sucesso |  | **Passos:**  Criar uma alga. Tentar arrastá-la além dos limites do mapa. Soltar e observar o comportamento. |  |
|  |  |  |  |
| **Observações:**  Este teste valida a correção e encerra a falha registrada no Caso de Teste 14\. |  |  |  |
|  |  |  |  |

| Caso de teste: 14R Prevenção de invocação sem seleção de entidade | Técnica:  Teste Funcional (Caixa-Preta) | Status:  Executado com sucesso Data: 12/12/2025 | Funcionalidade a ser testada: RF03 – Gerenciar vida marinha RF08 – Acessibilidade / Interação |
| :---- | :---- | :---- | :---- |
|  |  |  |  |
|  |  |  |  |
| **Pré-condição:**  Menu de invocação aberto. |  | **Entrada:**  O jogador abre o menu de invocação sem realizar nenhuma seleção manual. |  |
|  |  |  |  |
| **Resultado esperado:**  O sistema já possui uma entidade selecionada por padrão, impossibilitando a ação de invocar sem seleção. |  |  |  |
|  |  |  |  |
| **Resultado obtido:**  Teste executado com sucesso. Ao abrir o menu, uma entidade (alga ou peixe) já aparece selecionada automaticamente. |  | **Passos:**  Abrir o jogo. Acessar o menu de invocação. Observar o estado inicial da seleção. Confirmar que o botão “Invocar” não pode ser acionado sem entidade selecionada. |  |
|  |  |  |  |
| **Observações:**  Este teste valida a correção e encerra a falha registrada no Caso de Teste 14\. |  |  |  |
|  |  |  |  |

## 4- Testes Exploratórios

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
| **Resultado observado:** Início: (Após a adição) Oxi: 6.6   Bio: 2.5 Herb: 1.1  Carn: 0.0 Após 2 minutos: Oxi: 6.6   Bio: 3.9 Herb: 1.1  Carn: 0.0 O sistema manteve o oxigênio estável e aumentou levemente a biomassa, indicando equilíbrio entre produção e consumo. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
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

| Teste 6: Cenário mínimo não gera crash |  | Data: 27/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Jogo iniciado com somente 1 alga. |  |
|  |  |  |  |
| **Objetivo da exploração:**  Identificar comportamento com carga mínima. |  |  |  |
|  |  |  |  |
| **Resultado observado:** Teste executado com sucesso. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |
| **Observações:**  |  |  |  |

| Teste 7: Cenário cheio (stress test) |  | Data: 27/11/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Gustavo Linhares |  | **Ação realizada:**  Adicionar grande quantidade de peixes e algas |  |
|  |  |  |  |
| **Objetivo da exploração:**  Avaliar FPS, estabilidade e algum bug |  |  |  |
|  |  |  |  |
| **Resultado observado:** Teste executado com sucesso. |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |
| **Observações:**  |  |  |  |

| Teste 8: Experiência de jogo para novo jogador |  | Data: 14/12/2025 |  |
| :---- | ----- | :---- | ----- |
| **Testador:**  Otávio Linhares – novo jogador (não familiarizado com o jogo) |  | **Ação realizada:**  Iniciou o jogo sem instruções prévias. Criou um save com seu nome. Explorou inicialmente o menu de invocação. Tentou adicionar várias algas antes de adicionar peixes. Em seguida, adicionou peixes e observou as mudanças nos indicadores. Testou arrastar algas para diferentes posições do mapa. |  |
|  |  |  |  |
| **Objetivo da exploração:**  Avaliar se a interface do jogo permite que um jogador iniciante compreenda a ordem correta das ações (alga → peixe) e explore o ambiente de forma intuitiva, sem auxílio externo. |  |  |  |
|  |  |  |  |
| **Resultado observado:** O jogador conseguiu criar o save e navegar pelos menus sem dificuldades.Demonstrou entendimento rápido de que as algas são necessárias antes da adição de peixes. Conseguiu adicionar espécies corretamente após breve exploração.Interagiu com os elementos do ambiente de forma natural, sem apresentar dificuldades técnicas.  |  | **Anomalias/Bugs:** Nenhuma anomalia observada. |  |
|  |  |  |  |
| **Observações:** Apesar da boa compreensão geral, o jogador levou alguns minutos para associar diretamente os indicadores numéricos ao estado do ecossistema, indicando que explicações visuais ou tooltips poderiam facilitar ainda mais o aprendizado inicial. |  |  |  |

## 5- Conclusão

Este plano de testes assegura que as principais funcionalidades do jogo *Feed The Sea* serão validadas tanto manualmente quanto por meio de testes automatizados com LuaUnit. A estratégia cobre desde a lógica de recursos até a experiência do jogador, garantindo estabilidade, clareza e aderências aos objetivos do projeto.