defmodule TanokiWeb.ActivitySocket do
  use Phoenix.Socket
  alias Tanoki.Accounts
  alias Tanoki.Accounts.User
  alias Tanoki.Autologout.WorkerSupervisor

  channel "activity:*", TanokiWeb.ActivityChannel

  @impl true
  def connect(_params, socket, %{session: %{"user_token" => token}}) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:error, :not_allowed}

      %User{} = user ->
        channel_id = channel_id_from_user_token(token)
        {:ok, _pid} = WorkerSupervisor.find_or_start_worker(channel_id, user_token: token)

        {:ok,
         socket
         |> assign(:user_token, token)
         |> assign(:user, user)
         |> assign(:channel_id, channel_id)}
    end
  end

  def connect(_params, _socket, _connect_info), do: {:error, :not_allowed}

  defp channel_id_from_user_token(token) when is_binary(token) do
    hash = :crypto.hash(:sha256, token)

    hash
    |> String.slice(0..4)
    |> Base.encode16(case: :lower)
  end

  @impl true
  def id(socket), do: socket.assigns.user_token
end
