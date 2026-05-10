defmodule SaBot.Store do
  use GenServer
  @file_path "memoria_sapo.json"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def salvar_nota(texto), do: GenServer.cast(__MODULE__, {:add, texto})
  def listar_notas, do: GenServer.call(__MODULE__, :list)

  @impl true
  def init(_) do
    case File.read(@file_path) do
      {:ok, body} -> {:ok, Jason.decode!(body)}
      {:error, _} -> {:ok, %{"notas" => []}}
    end
  end

  @impl true
  def handle_cast({:add, texto}, state) do
    novas_notas = [texto | state["notas"]]
    novo_estado = %{state | "notas" => novas_notas}
    File.write!(@file_path, Jason.encode!(novo_estado))
    {:noreply, novo_estado}
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state["notas"], state}
  end
end
