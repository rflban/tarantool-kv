log = require('log')
json = require('json')


local function start()
    s = box.schema.create_space('kv')
    s:format {
        { name = 'key', type = 'string' },
        { name = 'value', type = 'any' }
    }
    s:create_index('primary', {
        type = 'hash',
        parts = { 1, 'string' }
    })
end


local function create(key, value)
    log.info('Create new record with key "%s" and value "%s"', key, json.encode(value))

    ok, record_or_error = pcall(function() return box.space.kv:insert{ key, value } end)
    if not ok then
        log.error(record_or_error)
        return nil
    end

    return record_or_error
end


local function read(key)
    log.info('Read by key "%s"', key)

    ok, record_or_error = pcall(function() return box.space.kv:get(key) end)
    if not ok or record_or_error == nil then
        log.error('No value with key "%s"', key)
        return nil
    end

    return {
        key = record_or_error[1],
        value = record_or_error[2]
    }
end


local function update(key, value)
    log.info('Update record with key "%s" and value "%s"', key, json.encode(value))

    ok, record_or_error = pcall(function() return box.space.kv:update(key, {{'=', 'value', value}}) end)
    if not ok then
        log.error('No value with key "%s"', key)
        return nil
    end

    return record_or_error
end


local function delete(key)
    log.info('Delete by key "%s"', key)

    ok, deleted_or_error = pcall(function() return box.space.kv:delete(key) end)
    if not ok then
        log.error('No value with key "%s"', key)
        return nil
    end

    return deleted_or_error
end


return {
    start = start,
    create = create,
    read = read,
    update = update,
    delete = delete
}

