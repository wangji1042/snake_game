defmodule SnakeGameWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "game:lobby", SnakeGameWeb.GameChannel

  ## Transports
  # transport :websocket, Phoenix.Socket.V2.WebSocket

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  # Socket ID（可选）
  @impl true
  def id(_socket), do: nil
end
