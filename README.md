# Überauth Discord

> Discord OAuth2 strategy for Überauth.

For additional documentation on Discord's OAuth implementation see [discord-oauth2-example](https://github.com/hammerandchisel/discord-oauth2-example).

## Installation

1. Setup your application at [Discord Developers](https://discordapp.com/developers/applications/me).

1. Add `:ueberauth_discord` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_discord, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_discord]]
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

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/discord

Or with options:

    /auth/discord?scope=identify%20email

By default the requested scope is "identify". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    discord: {Ueberauth.Strategy.Discord, [default_scope: "identify email connections guilds"]}
  ]
```

## License

Please see [LICENSE](https://github.com/schwarz/ueberauth_discord/blob/master/LICENSE) for licensing details.
