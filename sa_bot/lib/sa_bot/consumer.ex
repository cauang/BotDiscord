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

      "!sapo_coach " <> nome ->
        resposta = SaBot.Commands.sapo_coach(nome)
        Logger.info("Respondendo com sapo coach para #{nome}")
        Message.create(msg.channel_id, resposta)

      "!sapo_anotar " <> texto ->
        SaBot.Store.salvar_nota(texto)
        Logger.info("Nota salva: #{texto}")
        Message.create(msg.channel_id, "Sapo guardou sua nota no brejo!")

      "!sapo_notas" ->
        notas = SaBot.Store.listar_notas() |> Enum.join("\n- ")
        Logger.info("Listando notas")
        Message.create(msg.channel_id, "Memórias do Sapo:\n- " <> notas)

      "!clima " <> resto ->
        case String.split(resto) do
          [cidade, pais] ->
            resposta = SaBot.Commands.clima_brejo(cidade, pais)
            Logger.info("Consultando clima de #{cidade}, #{pais}")
            Message.create(msg.channel_id, resposta)
          _ ->
            Message.create(msg.channel_id, "Diga a cidade e o país (Ex: !clima Fortaleza BR)")
        end

      "!sapo_github " <> username ->
        resposta = SaBot.Commands.sapo_github(username)
        Logger.info("Buscando github de #{username}")
        Message.create(msg.channel_id, resposta)

      "!sapo_origem " <> nome ->
        resposta = SaBot.Commands.sapo_origem(nome)
        Logger.info("Buscando origem do nome #{nome}")
        Message.create(msg.channel_id, resposta)

      "!sapo_guardar_pokemon " <> pokemon ->
        resposta = SaBot.Commands.sapo_guardar_pokemon(pokemon)
        Logger.info("Guardando pokemon #{pokemon}")
        Message.create(msg.channel_id, resposta)

      "!sapo_moeda " <> resto ->
        case String.split(resto) do
          [valor, origem, destino] ->
            resposta = SaBot.Commands.sapo_moeda(valor, origem, destino)
            Logger.info("Convertendo moeda #{valor} #{origem} para #{destino}")
            Message.create(msg.channel_id, resposta)
          _ ->
            Message.create(msg.channel_id, "Formato incorreto. Tente: !sapo_moeda 10 USD BRL")
        end

      _ ->
        :ignore
    end
  end

  def handle_event(_), do: :ignore
end
