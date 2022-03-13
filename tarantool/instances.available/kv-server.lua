httpd = require('http.server')
json = require('json')
log = require('log')
os = require('os')
kv = require('kv')


box.cfg {
    log = 'kv-server.log'
}

box.once('kv-1.0', kv.start)


responses = {
    bad_request = function(message)
        return {
            status = 400,
            body = json.encode({
                message = message
            })
        }
    end,
    not_found = function(message)
        return {
            status = 404,
            body = json.encode({
                message = message
            })
        }
    end,
    confilct = function(message)
        return {
            status = 409,
            body = json.encode({
                message = message
            })
        }
    end,
    created = function()
        return {
            status = 201
        }
    end,
    no_content = function()
        return {
            status = 204
        }
    end,
    ok = function(obj)
        res = { status = 200 }

        if obj ~= nil then
            res.body = json.encode(obj)
        end

        return res
    end
}


function parse_json(req)
    return pcall(function() return req:json() end)
end


function add_record_handler(req)
    ok, body_or_error = parse_json(req)
    key, value = body_or_error.key, body_or_error.value
    if not ok or key == nil or value == nil or type(key) ~= 'string' then
        log.error('bad request: %s', json.encode(body_or_error))
        return responses.bad_request('invalid body')
    end

    rec = kv.create(key, value)
    if rec == nil then
        log.error('conflict for key: %s', key)
        return responses.confilct('key "' .. key .. '" is already exists')
    end

    return responses.created()
end


function update_record_handler(req)
    ok, body_or_error = parse_json(req)
    value = body_or_error.value
    if not ok or value == nil then
        log.error('bad request: %s', json.encode(body_or_error))
        return responses.bad_request('invalid body')
    end

    key = req:stash('key')
    rec = kv.update(key, value)
    if rec == nil then
        log.error('key does not exist: %s', key)
        return responses.not_found('key "' .. key .. '" does not exist')
    end

    return responses.ok()
end


function get_record_handler(req)
    key = req:stash('key')

    rec = kv.read(key)
    if rec == nil then
        log.error('key does not exist: %s', key)
        return responses.not_found('key "' .. key .. '" does not exist')
    end

    return responses.ok(rec)
end


function delete_record_handler(req)
    key = req:stash('key')

    rec = kv.delete(key)
    log.info(rec)
    if rec == nil then
        log.error('key does not exist: %s', key)
        return responses.not_found('key "' .. key .. '" does not exist')
    end

    return responses.no_content()
end


env_port = os.getenv('PORT')

local config = {
    host = '0.0.0.0',
    port = env_port and env_port or 8080
}


local server = httpd.new(config.host, config.port, {
    log_requests = true,
    log_errors = true,
})

server:route({ path = '/kv', method = 'POST' }, add_record_handler)
server:route({ path = '/kv/:key', method = 'PUT' }, update_record_handler)
server:route({ path = '/kv/:key', method = 'GET' }, get_record_handler)
server:route({ path = '/kv/:key', method = 'DELETE' }, delete_record_handler)

server:start()

