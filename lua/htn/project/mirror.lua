local Path = require('hn.path')
local Mirror = require("htl.project.mirror"):extend()

function Mirror.get_mappings()
    local mappings = List()

    for mirror_type, config in pairs(Mirror.type_configs) do
        if config.keymap_prefix then
            mappings:append({
                lhs_prefix = vim.b.hnetxt_opener_prefix .. config.keymap_prefix,
                fn = function(open_cmd) Mirror.open(mirror_type, open_cmd) end,
            })
        end
    end

    return mappings
end

function Mirror.open(mirror_type, open_command)
    local path = Mirror(Path.current_file()):get_mirror_path(mirror_type)
    Path.open(path, open_command)
end


return Mirror
