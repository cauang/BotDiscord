# SaBot

Um bot para o Discord feito em Elixir utilizando o framework Nostrum. Desenvolvido para a avaliação prática de Programação Funcional.

## Funcionalidades e Comandos
O bot implementa os seguintes comandos, cada um consumindo uma API REST diferente:
- `!cachorro` - Retorna a foto aleatória de um cachorro. (API: dog.ceo)
- `!sapo_coach <nome>` - O sapo dá um conselho para você. (API: adviceslip)
- `!clima <cidade> <pais>` - Informa a temperatura atual no local escolhido. (API: openweathermap) !!!!
- `!sapo_github <username>` - Informa a quantidade de repositórios públicos de um usuário. (API: github)
- `!sapo_moeda 10 USD BRL` - Converte moedas (ex: `!sapo_moeda 10 USD BRL`). (API: frankfurter) !!!!
- `!sapo_origem <nome>` - Advinha de qual país vem um nome (combina Nationalize.io e RestCountries).
- `!sapo_guardar_pokemon <nome>` - Procura um Pokémon na PokeAPI e salva em um arquivo local JSON usando a memória do bot.
- `!sapo_notas` - Lista tudo que foi anotado pelo bot.
- `!sapo_anotar <texto>` - Salva qualquer anotação solta no JSON.

## Como configurar o Token

O token do Discord **não está** diretamente no código para garantir segurança.

1. Na raiz do projeto (mesma pasta do `mix.exs`), crie um arquivo chamado `.env`
2. Dentro do `.env`, adicione as seguintes linhas:
```env
DISCORD_TOKEN=seu_token_do_discord_aqui
WEATHER_API_KEY=sua_chave_do_openweathermap
```

## Como rodar o bot

Existem duas maneiras principais:

**Via script PowerShell (Windows):**
Basta executar o arquivo `run.ps1` que já acompanha o projeto.
```powershell
.\run.ps1
```

**Manualmente via terminal:**
Certifique-se de que o seu ambiente está com as variáveis carregadas. E execute:
```bash
mix deps.get
mix run --no-halt
```
