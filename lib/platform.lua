local M = {}

function M.is_windows()
    return RUNTIME.osType == "Windows"
end

function M.is_macos()
    return RUNTIME.osType == "Darwin"
end

function M.is_linux()
    return RUNTIME.osType == "Linux"
end

function M.exe_ext()
    return M.is_windows() and ".exe" or ""
end

return M
