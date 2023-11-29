# Minimal HTTP server

This is a minimal HTTP server using
* Elixir
* Plug
* Bandit

Used for testing and debugging.

Supports HTTP/HTTPS and WebSockets.

## Usage

* replace self-signed certificates in `certs/` if HTTPS is needed;
* update `server.exs` to match your needs, drop the things you don't need;
* run the server
```bash
elixir server.exs
```

## Accessing

### HTTPS with `curl`
```bash
curl --resolve server:4001:127.0.0.1 --cacert certs/ca.crt 'https://server:4001/test'
```

### HTTP with `curl`
```bash
curl 'http://127.0.0.1:4000/test'
```

### WebSocket with browser & console

* Navigate to http://127.0.0.1:4000/
* Open the browser console
* Run code
```javascript
sock = new WebSocket("ws://localhost:4000/websocket");
sock.addEventListener("message", console.log);
sock.addEventListener("open", console.log)
...
sock.send("ping")
```

### WebSocket with `wscat`

```bash
npx wscat -c ws://127.0.0.1:4000/websocket
Connected (press CTRL+C to quit)
> ping
< pong
```

