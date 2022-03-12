FROM tarantool/tarantool:1.10.2

COPY tarantool/kv.lua /usr/local/share/tarantool
COPY tarantool/instances.available /usr/local/etc/tarantool/instances.available

RUN ln -s /usr/local/etc/tarantool/instances.available/kv-server.lua /usr/local/etc/tarantool/instances.enabled/kv-server.lua

CMD tarantoolctl start kv-server
