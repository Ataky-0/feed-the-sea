-- Ajusta caminho para a lib de testes
package.path = "../lib/?.lua;" .. package.path

-- Ajusta caminho para o código-fonte do projeto
package.path = "../../src/?.lua;" .. package.path

-- Ajusta caminho para libs internas chamadas com 'src.lib.*'
package.path = "../../?.lua;" .. package.path

local function getCurrentDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Controle para simular falha na escrita
local write_should_fail = false

-- Mock básico do LÖVE para testes fora do engine
local fake_fs = {}
_G.love = {
    filesystem = {
        createDirectory = function(_) end,
        getInfo = function(path) return fake_fs[path] and { type = "file" } or nil end,
        write = function(path, data)
            if write_should_fail then return false end  -- simula falha
            fake_fs[path] = data
            return true
        end,
        read = function(path) return fake_fs[path] end,
        getSaveDirectory = function() return "." end
    }
}

-- Importa módulos
local luaunit = require("luaunit")     -- framework de testes
local saves = require("savesManager")  -- módulo local em src/savesManager.lua

-- Define testes
TestSaves = {}

function TestSaves:testCreateSuccess()
    -- Criando um novo save
    local nome_save = "nome do save"
    local save, meta = saves.createSave(nome_save)

    -- Verifica se o save retornado tem os metadados corretos
    luaunit.assertEquals(meta.order, 1)
    luaunit.assertEquals(meta.name, nome_save)
    luaunit.assertEquals(meta.created_at, getCurrentDate())
    luaunit.assertEquals(meta.last_played, getCurrentDate())
    luaunit.assertEquals(meta.file, os.time() .. ".json")

    -- Verifica se a estrutura do save está correta
    local structure = saves.createSaveStruct()
    luaunit.assertEquals(save, structure)
    
end

function TestSaves:testCreateFail()
    fake_fs = {}              -- reseta mock
    write_should_fail = true  -- força falha

    -- chamada da função em modo seguro
    local ok, err = pcall(function()
        saves.createSave("save_erro")
    end)

    luaunit.assertFalse(ok) -- ok deve ser false porque deu erro
    -- Verifica se a mensagem de erro está correta
    luaunit.assertTrue(
        string.find(tostring(err), "Erro durante criação de save, arquivo não gerado.") ~= nil, 
        "Mensagem de erro incorreta"
    )

    write_should_fail = false  -- volta ao comportamento normal
end


-- Roda os testes
os.exit(luaunit.LuaUnit.run())
