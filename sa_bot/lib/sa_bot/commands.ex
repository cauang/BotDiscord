defmodule SaBot.Commands do

  def clima_brejo(cidade, pais) do
    IO.puts("Buscando clima para #{cidade}, #{pais}...")
    api_key = System.get_env("WEATHER_API_KEY")
    url = "https://api.openweathermap.org/data/2.5/weather?q=#{cidade},#{pais}&appid=#{api_key}&units=metric"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        data = Jason.decode!(body)
        temp = data["main"]["temp"]
        "Em #{cidade} faz #{temp}°C. Ótimo para um mergulho!"
      _ -> "O sapo não achou essa cidade no mapa."
    end
  end

  def imagem_sapo do
    {:ok, response} = HTTPoison.get("https://frog.pics/api/v1/frogs/random")
    Jason.decode!(response.body)["image_url"]
  end

  def sapo_coach(nome) do
    {:ok, response} = HTTPoison.get("https://api.adviceslip.com/advice")
    "Coach Sapo diz para #{nome}: " <> Jason.decode!(response.body)["slip"]["advice"]
  end
end
