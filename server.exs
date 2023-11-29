Mix.install([
  :bandit,
  :jason,
  :websock_adapter
])

http_port = 4000
https_port = 4001

######################################################################
# Plug webserver
######################################################################

defmodule MyPlug do
  require Logger

  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:urlencoded]
  )

  plug(Plug.Logger, log: :debug)

  plug(:match)
  plug(:dispatch)

  get "/test" do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, Jason.encode!(%{<<"result">> => <<"ok">>}))
  end

  get "/" do
    send_resp(conn, 200, """
    Use the JavaScript console to interact using websockets

    sock = new WebSocket("ws://localhost:4000/websocket");
    sock.addEventListener("message", console.log);
    sock.addEventListener("open", console.log)

    sock.send("ping")
    """)
  end

  get "/websocket" do
    conn
    |> WebSockAdapter.upgrade(WSEchoServer, [], timeout: 60_000)
    |> halt()
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end

######################################################################
# Websocket handler
######################################################################

defmodule WSEchoServer do
  import Logger

  def init(options) do
    {:ok, options}
  end

  def handle_in({"ping", [opcode: :text]}, state) do
    {:reply, :ok, {:text, "pong"}, state}
  end

  def terminate(reason, state) do
    Logger.info("Terminating websocket connection: #{inspect reason}")
    {:ok, state}
  end
end

######################################################################
# Starting the webserver
######################################################################

webservers = [{
  Bandit,
  [
    plug: MyPlug,
    scheme: :http,
    port: http_port
  ]
},
{
  Bandit,
  [
    plug: MyPlug,
    scheme: :https,
    certfile: Path.expand("../certs/server.crt",  __ENV__.file),
    keyfile: Path.expand("../certs/server.key",  __ENV__.file),
    port: https_port
  ]
}

]

{:ok, _} = Supervisor.start_link(webservers, strategy: :one_for_one)
Process.sleep(:infinity)

