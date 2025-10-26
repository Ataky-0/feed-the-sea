-- Ajusta caminho para a lib de testes
package.path = "../lib/?.lua;" .. package.path
package.path = "../../src/?.lua;" .. package.path
package.path = "../../?.lua;" .. package.path

local function getCurrentDate()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Mock básico do LÖVE para testes fora do engine
local fake_fs = {}
_G.love = {
    filesystem = {
        createDirectory = function(_) end,
        getInfo = function(path) return fake_fs[path] and { type = "file" } or nil end,
        write = function(path, data)
            fake_fs[path] = data
            return true
        end,
        read = function(path) return fake_fs[path] end,
        remove = function(path) fake_fs[path] = nil end,
    }
}

-- Importa módulos
local luaunit = require("luaunit")
local saves = require("savesManager")

-- Define testes
TestSaves = {}

-- ✅ TESTE 4: Deletar save (simples e visual)
function TestSaves:testDeleteSaveSimple()
    -- limpa ambiente
    fake_fs = {}

    -- Garante nomes únicos usando os.time
    local os_time_original = os.time
    local fake_time = os_time_original()
    os.time = function()
        fake_time = fake_time + 1
        return fake_time
    end

    -- Cria dois saves
    local _, meta1 = saves.createSave("save1")
    local _, meta2 = saves.createSave("save2")

    -- Restaura os.time
    os.time = os_time_original

    -- Mostra saves criados
    print("\nSaves criados:")
    print(" -", meta1.file, "(save1)")
    print(" -", meta2.file, "(save2)")

    -- Deleta o segundo save
    saves.deleteSave(meta2.file)
    print("\nSave deletado:", meta2.file)

    -- Lista saves restantes
    local listaFinal = saves.listSaves()
    print("\nLista final de saves:")
    for _, s in ipairs(listaFinal) do
        print(" -", s.file, "(" .. s.name .. ")")
    end

    -- Valida que o deletado não existe mais
    local deletadoExiste = false
    for _, s in ipairs(listaFinal) do
        if s.file == meta2.file then
            deletadoExiste = true
            break
        end
    end
    luaunit.assertFalse(deletadoExiste, "Save deletado ainda existe na lista final")
end


os.exit(luaunit.LuaUnit.run())
