defmodule SaBot.Consumer do
  use Nostrum.Consumer
  alias Nostrum.Api.Message
  require Logger

  def handle_event({:MESSAGE_CREATE, msg, _ws}) do
    Logger.info("Mensagem recebida: #{msg.content}")

    case msg.content do
      "!cachorro" ->
        resposta = SaBot.Commands.imagem_cachorro()
        Logger.info("Respondendo com imagem de cachorro")
        Message.create(msg.channel_id, resposta)

      "!conselho " <> nome ->
        resposta = SaBot.Commands.conselho(nome)
        Logger.info("Respondendo com conselho para #{nome}")
        Message.create(msg.channel_id, resposta)

      "!anotar " <> texto ->
        SaBot.Store.salvar_nota(texto)
        Logger.info("Nota salva: #{texto}")
        Message.create(msg.channel_id, "Nota salva com sucesso!")

      "!notas" ->
        notas = SaBot.Store.listar_notas() |> Enum.join("\n- ")
        Logger.info("Listando notas")
        Message.create(msg.channel_id, "Notas salvas:\n- " <> notas)

      "!pokedex" ->
        pokemons = SaBot.Store.listar_pokemons() |> Enum.join("\n- ")
        Logger.info("Listando pokemons")
        Message.create(msg.channel_id, "Pokémons capturados:\n- " <> pokemons)

      "!clima " <> resto ->
        case String.split(resto) do
          [cidade, pais] ->
            resposta = SaBot.Commands.clima(cidade, pais)
            Logger.info("Consultando clima de #{cidade}, #{pais}")
            Message.create(msg.channel_id, resposta)
          _ ->
            Message.create(msg.channel_id, "Diga a cidade e o país (Ex: !clima Fortaleza BR)")
        end

      "!github " <> username ->
        resposta = SaBot.Commands.github(username)
        Logger.info("Buscando github de #{username}")
        Message.create(msg.channel_id, resposta)

      "!origem " <> nome ->
        resposta = SaBot.Commands.origem(nome)
        Logger.info("Buscando origem do nome #{nome}")
        Message.create(msg.channel_id, resposta)

      "!pokemon " <> pokemon ->
        resposta = SaBot.Commands.guardar_pokemon(pokemon)
        Logger.info("Guardando pokemon #{pokemon}")
        Message.create(msg.channel_id, resposta)

      "!moeda " <> resto ->
        case String.split(resto) do
          [valor, origem, destino] ->
            resposta = SaBot.Commands.moeda(valor, origem, destino)
            Logger.info("Convertendo moeda #{valor} #{origem} para #{destino}")
            Message.create(msg.channel_id, resposta)
          _ ->
            Message.create(msg.channel_id, "Formato incorreto. Tente: !moeda 10 USD BRL")
        end

      _ ->
        :ignore
    end
  end

  def handle_event(_), do: :ignore
end
