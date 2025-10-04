#!/bin/bash
echo "🚀 Configurando estrutura do projeto Feed The Sea..."

# Cria pastas principais
mkdir -p src
mkdir -p tests
mkdir -p assets

# Cria exemplo de módulo
cat << 'EOF' > src/calc.lua
local calc = {}

function calc.add(a, b)
    return a + b
end

function calc.sub(a, b)
    return a - b
end

return calc
EOF

# Cria exemplo de teste
cat << 'EOF' > tests/test_example.lua
local luaunit = require("luaunit")
local calc = require("src.calc")

TestCalc = {}

function TestCalc:testAdd()
    luaunit.assertEquals(calc.add(2, 3), 5)
end

function TestCalc:testSub()
    luaunit.assertEquals(calc.sub(10, 4), 6)
end

os.exit(luaunit.LuaUnit.run())
EOF

echo "✅ Estrutura criada!"
echo "📁 Pastas: src/, tests/, assets/"
echo "📄 Teste exemplo: tests/test_example.lua"
echo "Para rodar o teste, use: lua tests/test_example.lua"
