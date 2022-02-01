# Überauth Discord

> Discord OAuth2 strategy for Überauth.

For additional documentation on Discord's OAuth implementation see [discord-oauth2-example](https://github.com/hammerandchisel/discord-oauth2-example).

## Installation

1. Setup your application at [Discord Developers](https://discord.com/developers/applications/me).

1. Add `:ueberauth_discord` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_discord, "~> 0.6"}]
    end
    ```

1. Add Discord to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        discord: {Ueberauth.Strategy.Discord, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Discord.OAuth,
      client_id: System.get_env("DISCORD_CLIENT_ID"),
      client_secret: System.get_env("DISCORD_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

    And make sure to set the correct redirect URI(s) in your Discord application to wire up the callback.

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

### Auth

Depending on the configured url you can initialize the request through:

    /auth/discord

Or with options:

    /auth/discord?scope=identify%20email&prompt=none&permissions=452987952

By default the requested scope is "identify". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    discord: {Ueberauth.Strategy.Discord, [default_scope: "identify email connections guilds"]}
  ]
```

You can also specify the `prompt` and `permissions` params to pass to Discord:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    discord: {Ueberauth.Strategy.Discord, [
      default_scope: "identify email connections guilds",
      prompt: "none",
      permissions: 452987952
    ]}
  ]
```

### Bot

This library can also be used to add bots to guilds. 

When adding bots, the `scope` should be set to `bot` and `permissions` should be set so your bot can perform actions in the host guild.

You can use the following parameters in addition to the ones specified for the user auth flow:
- `guild_id` - pre-select the guild to which the bot will be added
- `disable_guild_select` - disable the dropdown to select a guild (can improve UX by limiting choices)

Usage would look like the following:
```elixir
your_link_building_method(
  :request,
  "discord",
  scope: "bot",
  guild_id: guild_id,
  disable_guild_select: true,
  permissions: my_default_bot_permissions()
)
```

This should produce a link with the following format: 
```bash
https://discord.com/oauth2/authorize?client_id=<YOUR_CLIENT_ID>&disable_guild_select=true&guild_id=<SOME_GUILD_ID>&permissions=<DEFAULT_BOT_PERMISSIONS>&redirect_uri=<YOUR_DISCORD_CALLBACK_URI>&response_type=code&scope=bot&state=ebla7tFnIyX_FdmY5wjW8u7NJkc
```

## License

Please see [LICENSE](https://github.com/schwarz/ueberauth_discord/blob/master/LICENSE) for licensing details.
