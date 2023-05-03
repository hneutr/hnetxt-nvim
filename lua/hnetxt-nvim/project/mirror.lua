local Path = require('hneutil-nvim.path')
local Mirror = require("hnetxt-lua.project.mirror"):extend()

function Mirror.open(mirror_type, open_command)
    local path = Mirror(Path.current_file()):get_mirror_path(mirror_type)
    Path.open(path, open_command)
end

return Mirror
