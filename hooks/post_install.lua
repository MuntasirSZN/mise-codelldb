-- luacheck:ignore
local RUNTIME

function PLUGIN:PostInstall(ctx)
    local sdkInfo = ctx.sdkInfo[PLUGIN.name]
    local path = sdkInfo.path

    -- VSIX was downloaded; mise extracts archives automatically.
    -- CodeLLDB's adapter binary lives at extension/adapter/codelldb[.exe].
    local adapter_rel = "extension/adapter/codelldb"
    if RUNTIME.osType == "Windows" then
        adapter_rel = adapter_rel .. ".exe"
    end

    local src = path .. "/" .. adapter_rel
    local bin_dir = path .. "/bin"
    local dest = bin_dir .. "/codelldb"
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
    if RUNTIME.osType ~= "Windows" then
        os.execute('chmod +x "' .. dest .. '"')
    end

    -- Quick sanity check: print --help (adapter supports it)
    os.execute(dest .. " --help > /dev/null 2>&1")
end
