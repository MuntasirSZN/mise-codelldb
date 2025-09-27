local __cache = { versions = nil, ts = 0 }
local __ttl = 12 * 60 * 60

function PLUGIN:Available()
    local now = os.time()
    if __cache.versions and (now - (__cache.ts or 0)) < __ttl then
        return __cache.versions
    end

    local http = require("http")
    local json = require("json")

    local repo_url = "https://api.github.com/repos/vadimcn/codelldb/tags"

    local headers = {}
    if os.getenv("GITHUB_TOKEN") then
        headers["Authorization"] = "token " .. os.getenv("GITHUB_TOKEN")
    elseif os.getenv("GITHUB_API_TOKEN") then
        headers["Authorization"] = "token " .. os.getenv("GITHUB_API_TOKEN")
    end

    local resp, err = http.get({ url = repo_url, headers = headers })
    if err ~= nil then
        error("codelldb: failed to fetch tags: " .. err)
    end
    if not resp or resp.status_code ~= 200 then
        local code = resp and resp.status_code or "nil"
        local body = resp and resp.body or ""
        error("codelldb: GitHub tags API returned status " .. tostring(code) .. ": " .. body)
    end

    local ok, data = pcall(json.decode, resp.body)
    if not ok or type(data) ~= "table" then
        error("codelldb: failed to parse tags JSON")
    end

    local result = {}
    for _, tag_info in ipairs(data) do
        local v = tag_info.name
        local note = (type(v) == "string" and v:find("-%w")) and "pre-release" or nil
        table.insert(result, { version = v, note = note })
    end

    __cache.versions = result
    __cache.ts = now
    return result
end
