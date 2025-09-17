function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    local env = {
        { key = "PATH", value = mainPath .. "/bin" },
    }
    -- Help the adapter find bundled lldb libs on Unix systems
    if RUNTIME.osType == "Darwin" then
        table.insert(env, { key = "DYLD_LIBRARY_PATH", value = mainPath .. "/lldb/lib" })
    elseif RUNTIME.osType == "Linux" then
        table.insert(env, { key = "LD_LIBRARY_PATH", value = mainPath .. "/lldb/lib" })
    end
    return env
end
