defmodule Ueberauth.Strategy.Discord do
  @moduledoc """
  Discord Strategy for Überauth.
  """

  use Ueberauth.Strategy, uid_field: :id, default_scope: "identify"

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Discord authentication.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)
    opts = [scope: scopes]
    opts = if conn.params["state"] do
      Keyword.put(opts, :state, conn.params["state"])
    else
      opts
    end
    opts = Keyword.put(opts, :redirect_uri, callback_url(conn))

    redirect!(conn, Ueberauth.Strategy.Discord.OAuth.authorize_url!(opts))
  end

  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [redirect_uri: callback_url(conn)]
    token = Ueberauth.Strategy.Discord.OAuth.get_token!([code: code], opts)

    if token.access_token == nil do
      err = token.other_params["error"]
      desc = token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      conn
      |> store_token(token)
      |> fetch_user(token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  # Store the token for later use.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :discord_token, token)
  end

  defp fetch_user(conn, token) do
    path = "https://discordapp.com/api/users/@me"
    resp = OAuth2.AccessToken.get(token, path)

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
        when status_code in 200..399 ->
        put_private(conn, :discord_user, user)
      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  @doc """
  Includes the credentials from the Discord response.
  """
  def credentials(conn) do
    token = conn.private.discord_token
    scopes = (token.other_params["scope"] || "")
              |> String.split(",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      refresh_token: token.refresh_token,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.discord_user

    %Info{
      email: user["email"],
      image: "https://discordcdn.com/avatars/#{user["id"]}/#{user["avatar"]}.jpg",
      nickname: user["username"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the google callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.discord_token,
        user: conn.private.discord_user
      }
    }
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.discord_user[uid_field]
  end


  defp option(conn, key) do
    Dict.get(options(conn), key, Dict.get(default_options, key))
  end

end
