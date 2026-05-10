defmodule SaBot.Commands do

  def clima(cidade, pais) do
    busca = URI.encode("#{cidade},#{pais}")
    url = "https://wttr.in/#{busca}?format=j1"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        temp = data["current_condition"] |> hd() |> Map.get("temp_C")
        "Em #{cidade} faz #{temp}°C."
      _ -> "Cidade não encontrada."
    end
  end

  def imagem_cachorro do
    {:ok, response} = HTTPoison.get("https://dog.ceo/api/breeds/image/random")
    Jason.decode!(response.body)["message"]
  end

  def conselho(nome) do
    {:ok, response} = HTTPoison.get("https://api.adviceslip.com/advice")
    "Conselho para #{nome}: " <> Jason.decode!(response.body)["slip"]["advice"]
  end

  def github(username) do
    url = "https://api.github.com/users/#{username}"
    case HTTPoison.get(url, [{"User-Agent", "SaBot"}]) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        repos = data["public_repos"]
        "O usuário #{username} tem #{repos} repositórios públicos no GitHub."
      _ -> "Não foi possível encontrar esse desenvolvedor no GitHub."
    end
  end

  def moeda(valor, origem, destino) do
    url = "https://open.er-api.com/v6/latest/#{String.upcase(origem)}"
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        taxa = data["rates"][String.upcase(destino)]
        
        if taxa do
          case Float.parse(valor) do
            {v, _} ->
              resultado = v * taxa
              "Convertendo #{valor} #{String.upcase(origem)}, dá #{Float.round(resultado, 2)} #{String.upcase(destino)}."
            :error ->
              "O valor numérico '#{valor}' é inválido."
          end
        else
          "Moeda de destino não encontrada."
        end
      _ -> "Formato incorreto. Tente algo como: !moeda 10 USD BRL"
    end
  end

  def origem(nome) do
    url_nationalize = "https://api.nationalize.io/?name=#{nome}"

    with {:ok, %{status_code: 200, body: body1}} <- HTTPoison.get(url_nationalize),
         %{"country" => [%{"country_id" => country_id} | _]} <- Jason.decode!(body1),
         url_countries = "https://restcountries.com/v3.1/alpha/#{country_id}",
         {:ok, %{status_code: 200, body: body2}} <- HTTPoison.get(url_countries),
         [country_data | _] <- Jason.decode!(body2),
         country_name <- country_data["name"]["common"] do

      "A origem provável do nome '#{nome}' é do país: #{country_name}."
    else
      _ -> "Não foi possível adivinhar a origem desse nome."
    end
  end

  def guardar_pokemon(nome) do
    url = "https://pokeapi.co/api/v2/pokemon/#{String.downcase(nome)}"
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        id = data["id"]
        nome_poke = data["name"]
        imagem_url = data["sprites"]["front_default"]
        
        texto = "Pokémon: #{String.capitalize(nome_poke)} (ID: #{id})"
        SaBot.Store.salvar_pokemon(texto)
        "Pokémon #{String.capitalize(nome_poke)} salvo com sucesso!\n#{imagem_url}"
      _ -> "Pokémon não encontrado."
    end
  end
end
