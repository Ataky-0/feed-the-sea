# Feed The Sea

## O que é?

**Feed The Sea** se trata de um jogo _Desktop (Win/Mac/Linux)_ de Sandbox onde você pode controlar livremente uma secção do mar, sendo esta secção passível de ampliação. Será o seu lugar, onde você é convidado a limpar da poluição humana e então dar dignidade ao seu ambiente, enchendo-o de vida através da alocação de vida marítima compatível como algas e peixes. Você é encorajado a manter o ambiente balanceado com disponibilidade ideal de oxigênio e comida tanto para herbívoros quanto para carnívoros e claro, onívoros também.

## Como fizemos?

A tecnologia que decidimos usar dado a idealização pelo fácil desenvolvimento e manutenabilidade foi a línguagem de programação [Lua](https://www.lua.org/) ([LuaJIT](https://luajit.org/)) através do Framework de jogo 2D [LÖVE](https://www.love2d.org/). A criação do jogo se dá através da modularização fabricada pela nossa própria arquitetura para o jogo onde a `main.lua` serve mais como uma interface para conexões internas em várias camadas tornando possível a criação e existência de múltiplas _cenas_ carregadas e descarregadas dinâmicamente.

## Como testar?

Para rodar o jogo localmente, atualmente ainda não disponibilizamos uma maneira de fácil acesso ou mesmo intuitivo para esta finalidade, porém, o processo não é complexo e qualquer indivíduo deve conseguir facilmente, segue um bullet de instruções passo a passo para rodar o jogo localmente tanto via Terminal/CMD quanto Interface Gráfica **(CASO POSSUA UM .LOVE DO JOGO)**:

### Preparar ->

Para todos os sistemas operacionais é necessário primeiro ter o [LÖVE](https://www.love2d.org/) instalado.

### Terminal ->

- 1: Clone o repositório e navegue até ele: `git clone https://github.com/Ataky-0/feed-the-sea`, `cd feed-the-sea`.

- 2: Agora, navegue até o diretório onde o projeto do jogo está de fato: `cd Project`.

- 3: Execute o projeto através do comando `love .`, note que o '.' serve para indicar o diretório atual, você poderia portanto a partir do passo 1 rodar `love Project/`, o que também funcionaria. 

### Interface Gráfica ->

- 1: Baixe o conteúdo do repositório clicando no botão azul `Code` e depois em `Download ZIP`, os nomes podem variar de acordo com a linguagem configurada no seu GitHub.

- 2: Extraia o arquivo `feed-the-sea-{BRANCH}.zip` e em seguida busque um arquivo `.love` e o execute normalmente por meio do seu gerenciador de arquivos. 

**OBS:** Caso não tenha nenhum `.love`, que é o mais provável, você pode criar um facilmente compactando o diretório `Project/` e alterando a extensão do arquivo compactado gerado para `.love` e então executá-lo como instruído no início da etapa 2.