# Guia de Estudos - Bot Discord em Elixir (Nostrum)

Este documento foi preparado para te ajudar a estudar para a arguição com o professor. Ele explica a estrutura do projeto, as sintaxes do Elixir utilizadas e como as requisições de API (REST) e o JSON funcionam no código.

---

## 1. Arquitetura do Projeto

O projeto foi dividido em 4 módulos principais para separar as responsabilidades, seguindo as boas práticas e o modelo OTP (Open Telecom Platform) do Elixir:

1. **`SaBot` (`lib/sa_bot.ex`)**: É o ponto de entrada da aplicação (`Application`). Ele inicia a árvore de supervisão (`Supervisor`) e levanta os processos filhos: o `Store` e o `Consumer`.
2. **`SaBot.Consumer` (`lib/sa_bot/consumer.ex`)**: Fica "escutando" os eventos do Discord. É o handler de mensagens. Ele recebe a mensagem e usa **Pattern Matching** para decidir qual comando rodar.
3. **`SaBot.Commands` (`lib/sa_bot/commands.ex`)**: Onde a mágica (as regras de negócio) acontece. Cada comando tem uma função pura e isolada que faz a chamada de rede (HTTPoison), formata a resposta e devolve a string para o Consumer enviar pro chat.
4. **`SaBot.Store` (`lib/sa_bot/store.ex`)**: O módulo de persistência, escrito usando um `GenServer`. Ele guarda as notas na memória RAM enquanto o bot está rodando e salva no arquivo `memoria_sapo.json` para não perder os dados quando o bot for desligado.

---

## 2. Sintaxe e Conceitos do Elixir

Seu professor vai cobrar o entendimento de alguns conceitos puramente funcionais que usamos no código:

### Pattern Matching (Casamento de Padrões)
No Elixir, o sinal de igual `=` não é apenas atribuição, ele é uma "afirmação de igualdade". Além disso, usamos Pattern Matching em blocos `case` e na assinatura das funções.

**Exemplo no `Consumer`:**
```elixir
# Aqui quebramos a string da mensagem e já forçamos que o lado esquerdo
# seja uma lista com 3 elementos. Se o usuário mandar mais ou menos, vai cair no '_' (erro).
case String.split(resto) do
  [valor, origem, destino] ->
    resposta = SaBot.Commands.moeda(valor, origem, destino)
  _ ->
    Message.create(msg.channel_id, "Formato incorreto.")
end
```

**Exemplo com Strings (`<>`):**
```elixir
# Se a string começar exatamente com "!moeda ", o resto da frase vai 
# parar automaticamente na variável 'resto'.
"!moeda " <> resto ->
```

### O Pipe Operator (`|>`)
A grande beleza de linguagens funcionais. O pipe joga o resultado da função da esquerda como sendo o PRIMEIRO argumento da função da direita.

**Exemplo no código de clima:**
```elixir
temp = data["current_condition"] |> hd() |> Map.get("temp_C")

# O que ele faz por debaixo dos panos:
# 1. Pega a lista dentro do JSON: data["current_condition"]
# 2. hd(lista) -> Pega a "cabeça" (primeiro elemento) da lista.
# 3. Map.get(elemento, "temp_C") -> Pega o valor da temperatura.
```

### O bloco `with`
Usado no comando `!origem`, o `with` serve para encadear lógicas que podem dar erro. Ele tenta rodar linha por linha da direita para a esquerda (`<-`). Se TODAS derem certo, ele roda o bloco `do`. Se alguma falhar (ex: a API cair ou o JSON vir vazio), ele pula direto pro `else` e não trava o bot.

```elixir
with {:ok, %{status_code: 200, body: body1}} <- HTTPoison.get(url_nationalize),
     %{"country" => [%{"country_id" => country_id} | _]} <- Jason.decode!(body1) do
  # Sucesso!
else
  _ -> "Tratamento de erro geral aqui"
end
```

---

## 3. Como as APIs e os JSONs são manipulados?

Todas as APIs REST devolvem um texto puro formatado em JSON. Nós usamos a biblioteca `HTTPoison` para buscar esse texto e a biblioteca `Jason` para transformar esse texto em Mapas e Listas no Elixir.

O fluxo de qualquer comando segue o mesmo padrão:
1. Chama a URL usando `HTTPoison.get(url)`
2. Verifica se a resposta foi HTTP 200 OK via Pattern Matching (`{:ok, %{status_code: 200, body: body}}`)
3. Converte a string `body` usando `Jason.decode!(body)`
4. Navega pelas chaves do dicionário para achar a informação desejada.

### Exemplo 1: Dog API (`!cachorro`)
- **Como chega para você (JSON da web):**
```json
{
  "message": "https://images.dog.ceo/breeds/husky/n02110185_10047.jpg",
  "status": "success"
}
```
- **Como extraímos no Elixir:**
```elixir
data = Jason.decode!(body)
url_da_imagem = data["message"]
```

### Exemplo 2: ExchangeRate API (`!moeda`)
- **Como chega para você:**
```json
{
  "result": "success",
  "base_code": "USD",
  "rates": {
    "BRL": 4.98,
    "EUR": 0.92,
    "JPY": 150.2
  }
}
```
- **Como extraímos no Elixir:**
Para achar o valor do Real (BRL), precisamos entrar na chave `"rates"` e depois buscar a chave `"BRL"`.
```elixir
data = Jason.decode!(body)
taxa = data["rates"]["BRL"]
```

### Exemplo 3: PokeAPI (`!pokemon`)
- **Como chega para você (Resumo do JSON gigantesco que a API devolve):**
```json
{
  "id": 25,
  "name": "pikachu",
  "sprites": {
    "front_default": "https://raw.githubusercontent.com/.../25.png"
  }
}
```
- **Como extraímos no Elixir:**
```elixir
data = Jason.decode!(body)
id = data["id"]
nome_poke = data["name"]
imagem_url = data["sprites"]["front_default"]
```

---

## 4. O Módulo de Persistência (`SaBot.Store`)

O Elixir não possui "variáveis globais" ou "estados mutáveis". Para contornar isso e fazer o banco de dados temporário, usamos o **GenServer** (Generic Server).
- É como um mini-servidor que roda na sua máquina segurando o estado (`state`).
- **`handle_cast`**: Chamada assíncrona ("não quero resposta, só guarde isso"). Usado para adicionar notas. Após adicionar na memória, ele também regrava o arquivo `.json`.
- **`handle_call`**: Chamada síncrona ("fique travado até me devolver uma resposta"). Usado para ler as notas atuais.
- **`init`**: Roda quando o bot liga. Tenta ler o `memoria_sapo.json`. Se não existir, ele cria o estado inicial como um mapa vazio `%{"notas" => []}`.

---
*Dica para a arguição: Pratique ler o código em voz alta e usar os termos em inglês ("Pattern Matching", "Pipe Operator", "Map"). Se o professor pedir para ver um JSON na hora, basta abrir a URL da API no navegador da Web para mostrar.*
