local exports = {}

function exports.pack_after(i, ...)
    local front = {unpack({...}, 1, i)}
    front[i + 1] = {select(i + 1, ...)}

    return unpack(front, 1, i + 1)
end

function exports.shell(bin, args, on_exit, throw)
    local stdout, stderr = vim.uv.new_pipe(), vim.uv.new_pipe()
    local process

    local function on_exit_outer(exit_code, signal)
        process:close()

        local streams = {stdout, stderr}
        local remaining = #streams

        for i, stream in ipairs(streams) do
            streams[i] = ""

            vim.uv.read_start(stream, function(err, data)
                if data then streams[i] = streams[i] .. data end

                if not data or err then
                    stream:close()
                    remaining = remaining - 1

                    if remaining == 0 then
                        on_exit(exit_code, signal, unpack(streams))
                    end
                end

                if err then error(err) end
            end)
        end
    end

    local result
    process, result = exports.pack_after(1, vim.uv
                                             .spawn(bin, {
        args = args,
        stdio = {nil, stdout, stderr}
    }, on_exit_outer))

    if process then
        local pid = unpack(result)

        return true, {handle = process, pid = pid}
    end

    local err_desc, err_name = unpack(result)

    stdout:close()
    stderr:close();

    if throw or throw == nil then
        error("Failed to spawn the process: " ..
                  (({ENOENT = "binary not found"})[err_name] or err_desc), 2)
    end

    return false, {name = err_name, desc = err_desc}
end

function exports.parse_call(string)
    local bin
    local args = {}

    for word in string:gmatch("%S+") do
        if not bin then
            bin = word
        else
            table.insert(args, word)
        end
    end

    return bin, args
end

return exports
