FROM tarantool/tarantool

COPY tarantool/kv.lua /usr/local/share/tarantool
COPY tarantool/instances.available /usr/local/etc/tarantool/instances.available

RUN ln -s /usr/local/etc/tarantool/instances.available/kv-server.lua /usr/local/etc/tarantool/instances.enabled/kv-server.lua

CMD tarantoolctl start kv-server && tail -f kv-server.log
