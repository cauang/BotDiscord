defmodule SaBot.Commands do

  def clima_brejo(cidade, pais) do
    busca = URI.encode("#{cidade},#{pais}")
    url = "https://wttr.in/#{busca}?format=j1"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        temp = data["current_condition"] |> hd() |> Map.get("temp_C")
        "Em #{cidade} faz #{temp}°C. Ótimo para um mergulho!"
      _ -> "O sapo não achou essa cidade no mapa."
    end
  end

  def imagem_cachorro do
    {:ok, response} = HTTPoison.get("https://dog.ceo/api/breeds/image/random")
    Jason.decode!(response.body)["message"]
  end

  def sapo_coach(nome) do
    {:ok, response} = HTTPoison.get("https://api.adviceslip.com/advice")
    "Coach Sapo diz para #{nome}: " <> Jason.decode!(response.body)["slip"]["advice"]
  end

  def sapo_github(username) do
    url = "https://api.github.com/users/#{username}"
    case HTTPoison.get(url, [{"User-Agent", "SaBot"}]) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        repos = data["public_repos"]
        "O usuário #{username} tem #{repos} repositórios públicos no GitHub!"
      _ -> "O sapo não encontrou esse desenvolvedor no GitHub."
    end
  end

  def sapo_moeda(valor, origem, destino) do
    url = "https://open.er-api.com/v6/latest/#{String.upcase(origem)}"
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        taxa = data["rates"][String.upcase(destino)]
        
        if taxa do
          case Float.parse(valor) do
            {v, _} ->
              resultado = v * taxa
              "Convertendo #{valor} #{String.upcase(origem)}, dá #{Float.round(resultado, 2)} #{String.upcase(destino)}!"
            :error ->
              "O valor numérico '#{valor}' é inválido."
          end
        else
          "O sapo não encontrou essa moeda de destino."
        end
      _ -> "O sapo se confundiu com essas moedas. Tente algo como: !sapo_moeda 10 USD BRL"
    end
  end

  def sapo_origem(nome) do
    url_nationalize = "https://api.nationalize.io/?name=#{nome}"

    with {:ok, %{status_code: 200, body: body1}} <- HTTPoison.get(url_nationalize),
         %{"country" => [%{"country_id" => country_id} | _]} <- Jason.decode!(body1),
         url_countries = "https://restcountries.com/v3.1/alpha/#{country_id}",
         {:ok, %{status_code: 200, body: body2}} <- HTTPoison.get(url_countries),
         [country_data | _] <- Jason.decode!(body2),
         country_name <- country_data["name"]["common"] do

      "O sapo jogou as runas e acha que o nome '#{nome}' vem do país:  #{country_name}!"
    else
      _ -> "O sapo não conseguiu adivinhar a origem desse nome."
    end
  end

  def sapo_guardar_pokemon(nome) do
    url = "https://pokeapi.co/api/v2/pokemon/#{String.downcase(nome)}"
    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        id = data["id"]
        nome_poke = data["name"]
        texto = "Pokémon: #{String.capitalize(nome_poke)} (ID: #{id})"
        SaBot.Store.salvar_nota(texto)
        "O sapo encontrou e guardou o #{String.capitalize(nome_poke)} no brejo!"
      _ -> "Esse Pokémon não existe na Pokédex do sapo."
    end
  end
end
