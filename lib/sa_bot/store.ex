defmodule SaBot.Store do
  use GenServer
  @file_path "memoria_sapo.json"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def salvar_nota(texto), do: GenServer.cast(__MODULE__, {:add_nota, texto})
  def listar_notas, do: GenServer.call(__MODULE__, :list_notas)

  def salvar_pokemon(texto), do: GenServer.cast(__MODULE__, {:add_pokemon, texto})
  def listar_pokemons, do: GenServer.call(__MODULE__, :list_pokemons)

  @impl true
  def init(_) do
    case File.read(@file_path) do
      {:ok, body} -> 
        data = Jason.decode!(body)
        data = Map.put_new(data, "notas", [])
        data = Map.put_new(data, "pokemons", [])
        {:ok, data}
      {:error, _} -> 
        {:ok, %{"notas" => [], "pokemons" => []}}
    end
  end

  @impl true
  def handle_cast({:add_nota, texto}, state) do
    novas_notas = [texto | state["notas"]]
    novo_estado = %{state | "notas" => novas_notas}
    File.write!(@file_path, Jason.encode!(novo_estado))
    {:noreply, novo_estado}
  end

  @impl true
  def handle_cast({:add_pokemon, texto}, state) do
    novos_pokemons = [texto | state["pokemons"]]
    novo_estado = %{state | "pokemons" => novos_pokemons}
    File.write!(@file_path, Jason.encode!(novo_estado))
    {:noreply, novo_estado}
  end

  @impl true
  def handle_call(:list_notas, _from, state) do
    {:reply, state["notas"], state}
  end

  @impl true
  def handle_call(:list_pokemons, _from, state) do
    {:reply, state["pokemons"], state}
  end
end
