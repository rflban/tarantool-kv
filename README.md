# Tarantool simple key-value store

## Deploy
https://rflban-tarantool-kv.herokuapp.com/

## API
- POST /kv body: {key: "test", "value": {SOME ARBITRARY JSON}} 
- PUT kv/{id} body: {"value": {SOME ARBITRARY JSON}}
- GET kv/{id} 
- DELETE kv/{id}
