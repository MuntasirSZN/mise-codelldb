function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local http = require("http")

    local os_name = RUNTIME.osType:lower()
    local arch = RUNTIME.archType

    local candidates = {}
    if os_name == "linux" then
        if arch == "amd64" or arch == "x86_64" then
            candidates = { "codelldb-linux-x64.vsix", "codelldb-x86_64-linux.vsix" }
        elseif arch == "arm64" or arch == "aarch64" then
            candidates = { "codelldb-linux-arm64.vsix", "codelldb-aarch64-linux.vsix" }
        elseif arch == "arm" then
            candidates = { "codelldb-linux-armhf.vsix", "codelldb-arm-linux.vsix" }
        end
    elseif os_name == "darwin" then
        if arch == "amd64" or arch == "x86_64" then
            candidates = { "codelldb-darwin-x64.vsix", "codelldb-x86_64-darwin.vsix" }
        elseif arch == "arm64" or arch == "aarch64" then
            candidates = { "codelldb-darwin-arm64.vsix", "codelldb-aarch64-darwin.vsix" }
        end
    elseif os_name == "windows" then
        candidates = { "codelldb-win32-x64.vsix", "codelldb-x86_64-windows.vsix" }
    end

    if #candidates == 0 then
        error("Unsupported platform for codelldb: " .. os_name .. "/" .. arch)
    end

    local base = "https://github.com/vadimcn/codelldb/releases/download/" .. version .. "/"
    local chosen
    for _, file in ipairs(candidates) do
        local url = base .. file
        local resp = select(1, http.get({ url = url }))
        if resp and resp.status_code == 200 then
            chosen = file
            break
        end
    end

    if not chosen then
        error("codelldb: no VSIX found for platform: " .. os_name .. "/" .. arch)
    end

    return {
        version = version,
        url = base .. chosen,
        note = "Downloading codelldb " .. version .. " (" .. chosen .. ")",
    }
end
