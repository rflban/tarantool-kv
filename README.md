# Tarantool simple key-value store

## Deploy
http://165.232.81.231/

## API
- POST /kv body: {key: "test", "value": {SOME ARBITRARY JSON}} 
- PUT kv/{id} body: {"value": {SOME ARBITRARY JSON}}
- GET kv/{id} 
- DELETE kv/{id}
