defmodule SaBot do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SaBot.Store,
      SaBot.Consumer
    ]

    opts = [strategy: :one_for_one, name: SaBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
