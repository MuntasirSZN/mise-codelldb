function PLUGIN:Available()
    local http = require("http")
    local json = require("json")

    -- CodeLLDB releases/tags live under vadimcn/codelldb
    local repo_url = "https://api.github.com/repos/vadimcn/codelldb/tags"

    local resp, err = http.get({ url = repo_url })
    if err ~= nil then
        error("Failed to fetch versions: " .. err)
    end
    if resp.status_code ~= 200 then
        error("GitHub API returned status " .. resp.status_code .. ": " .. resp.body)
    end

    local tags = json.decode(resp.body)
    local result = {}

    for _, tag_info in ipairs(tags) do
        local version = tag_info.name -- typically like "v1.11.5"
        table.insert(result, { version = version })
    end

    return result
end
