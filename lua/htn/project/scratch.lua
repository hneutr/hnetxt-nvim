local BufferLines = require("hn.buffer_lines")
local Path = require('hn.path')
local Mirror = require('htn.project.mirror')

return function(mode)
    local lines = BufferLines.selection.get({mode = mode})
    BufferLines.selection.cut({mode = mode})

    if lines[#lines] ~= "" then
      table.insert(lines, "")
    end

    local path = Mirror(Path.current_file()):get_mirror_path('scratch')

    if Path.exists(path) then
        lines[#lines + 1] = Path.read(path)
    end

    Path.write(path, lines)
end
