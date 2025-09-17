function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path

    -- VSIX was downloaded; mise extracts archives automatically.
    -- CodeLLDB's adapter binary lives at extension/adapter/codelldb[.exe].
    local adapter_rel = "extension/adapter/codelldb"
    -- luacheck:ignore
    if RUNTIME.osType == "Windows" then
        adapter_rel = adapter_rel .. ".exe"
    end

    local src = path .. "/" .. adapter_rel
    local bin_dir = path .. "/bin"
    local dest = bin_dir .. "/codelldb"
    -- luacheck:ignore
    if RUNTIME.osType == "Windows" then
        dest = dest .. ".exe"
    end

    -- If adapter not present yet, try extracting VSIX (zip) into path
    local function file_exists(p)
        local f = io.open(p, "rb")
        if f then
            f:close()
            return true
        end
        return false
    end

    if not file_exists(src) then
        -- Find a downloaded VSIX in the root path
        local vsix
        local p = io.popen("ls -1 '" .. path .. "' | grep -E '^codelldb-.*\\.vsix$' 2>/dev/null")
        if p then
            vsix = p:read("*l")
            p:close()
        end
        if vsix and vsix ~= "" then
            local vsix_path = path .. "/" .. vsix
            -- luacheck:ignore
            if RUNTIME.osType == "Windows" then
                os.execute(
                    "powershell -NoProfile -Command \"Expand-Archive -Path '"
                        .. vsix_path
                        .. "' -DestinationPath '"
                        .. path
                        .. "' -Force\""
                )
            else
                os.execute("unzip -q '" .. vsix_path .. "' -d '" .. path .. "'")
            end
        end
    end

    -- Recompute after extraction attempt
    if not file_exists(src) then
        error("codelldb adapter not found after install: " .. src)
    end

    os.execute("mkdir -p " .. bin_dir)
    os.execute('cp "' .. src .. '" "' .. dest .. '"')
    -- luacheck:ignore
    if RUNTIME.osType ~= "Windows" then
        os.execute('chmod +x "' .. dest .. '"')
    end

    -- Ensure adapter can find bundled LLDB libs at '<install>/lldb/lib'.
    -- VSIX bundles them under 'extension/lldb', so create a symlink for Unix.
    -- On Windows, the adapter finds DLLs alongside the executable.
    if RUNTIME.osType ~= "Windows" then
        local lldb_src_dir = path .. "/extension/lldb"
        local lldb_dest_dir = path .. "/lldb"
        -- Try to create/refresh a symlink. If it fails, fall back to copying.
        local link_ok = os.execute("ln -sfn '" .. lldb_src_dir .. "' '" .. lldb_dest_dir .. "'")
        if link_ok ~= 0 then
            os.execute("rm -rf '" .. lldb_dest_dir .. "' 2>/dev/null || true")
            os.execute("cp -a '" .. lldb_src_dir .. "' '" .. lldb_dest_dir .. "'")
        end
    end

    -- Quick sanity check: print --help (adapter supports it)
    os.execute(dest .. " --help > /dev/null 2>&1")
end
