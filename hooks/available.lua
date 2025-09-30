local cache = { versions = nil, timestamp = 0 }
local cache_ttl = 12 * 60 * 60

local function parse_github_tags(body)
    local json = require("json")
    local ok, data = pcall(json.decode, body)
    if not ok or type(data) ~= "table" then
        return nil
    end
    return data
end

local function parse_ungh_releases(body)
    local json = require("json")
    local ok, data = pcall(json.decode, body)
    if not ok or type(data) ~= "table" then
        return nil
    end
    if data.releases and type(data.releases) == "table" then
        -- Convert ungh format to GitHub tags format
        local tags = {}
        for _, release in ipairs(data.releases) do
            table.insert(tags, { name = release.tag or release.name })
        end
        return tags
    end
    return nil
end

function PLUGIN:Available()
    local now = os.time()
    if cache.versions and cache.timestamp and (now - cache.timestamp) < cache_ttl then
        return cache.versions
    end

    local http = require("http")

    local headers = {}
    local tok = os.getenv("GITHUB_TOKEN") or os.getenv("GITHUB_API_TOKEN")
    if tok and #tok > 0 then
        headers["Authorization"] = "token " .. tok
    end

    local gh_url = "https://api.github.com/repos/vadimcn/codelldb/tags"
    local resp = select(1, http.get({ url = gh_url, headers = headers }))
    local tags
    if resp and resp.status_code == 200 then
        tags = parse_github_tags(resp.body)
    end

    if not tags then
        local ungh_url = "https://ungh.cc/repos/vadimcn/codelldb/releases"
        local r2 = select(1, http.get({ url = ungh_url, headers = headers }))
        if r2 and r2.status_code == 200 then
            tags = parse_ungh_releases(r2.body)
        end
    end

    if not tags then
        local code = resp and resp.status_code or "nil"
        error("codelldb: failed to fetch tags from GitHub (" .. tostring(code) .. ") and ungh.cc")
    end

    local result = {}
    for _, tag_info in ipairs(tags) do
        local v = tag_info.name
        local note = (type(v) == "string" and v:find("-%w")) and "pre-release" or nil
        table.insert(result, { version = v, note = note })
    end

    cache.versions = result
    cache.timestamp = now
    return result
end
