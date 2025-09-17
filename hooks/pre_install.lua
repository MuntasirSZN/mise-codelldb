-- luacheck:ignore
local RUNTIME

function PLUGIN:PreInstall(ctx)
    local version = ctx.version

    local os_name = RUNTIME.osType:lower()
    local arch = RUNTIME.archType

    -- Map to codelldb VSIX filenames
    local file
    if os_name == "linux" then
        if arch == "amd64" or arch == "x86_64" then
            file = "codelldb-linux-x64.vsix"
        elseif arch == "arm64" or arch == "aarch64" then
            file = "codelldb-linux-arm64.vsix"
        elseif arch == "arm" then
            file = "codelldb-linux-armhf.vsix"
        end
    elseif os_name == "darwin" then
        if arch == "amd64" or arch == "x86_64" then
            file = "codelldb-darwin-x64.vsix"
        elseif arch == "arm64" or arch == "aarch64" then
            file = "codelldb-darwin-arm64.vsix"
        end
    elseif os_name == "windows" then
        file = "codelldb-win32-x64.vsix"
    end

    if not file then
        error("Unsupported platform for codelldb: " .. os_name .. "/" .. arch)
    end

    -- Version is expected to include the 'v' prefix (from tags)
    local url = "https://github.com/vadimcn/codelldb/releases/download/" .. version .. "/" .. file

    return {
        version = version,
        url = url,
        note = "Downloading codelldb " .. version .. " (" .. file .. ")",
    }
end
