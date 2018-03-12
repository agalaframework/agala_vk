defmodule Agala.Provider.Vk do
  use Agala.Provider
  require Logger
  @moduledoc """
  Module providing adapter for Vk
  """
  @headers [{"Content-Type", "application/json"}]

  def base_url(method_name) do
    "https://api.vk.com/method/" <> method_name
  end

  def api_version, do: "5.67"

  def init(bot_params, module) do
    bot_params = Map.put(bot_params, :private, %{
      http_opts: bot_params.provider_params.hackney_opts
                 |> set_timeout(bot_params, module),
      wait: get_in(bot_params, [:provider_params, :poll_wait]) || 25,
      mode: set_mode(bot_params)
    })
    case module do
      :receiver -> {:ok, init_longpolling_server(bot_params)}
      :responser -> {:ok, bot_params}
    end
  end

  def init_longpolling_server(bot_params) do
    with {:ok, %HTTPoison.Response{body: body}} <- get_longpolling_server_params(bot_params),
         {:ok, %{"response" => server_params}} <- Poison.decode(body)
    do
      bot_params
      |> put_in([:private, :key], server_params["key"])
      |> put_in([:private, :server], server_params["server"])
      # If server was corrupted, we dont want to lose updates so we shift ts a bit back
      |> put_in([:private, :ts], Agala.get(bot_params, :poll_server_ts) || server_params["ts"])
      |> put_in([:private, :pts], server_params["pts"])
    else
    {:error, _} ->
      Logger.error("VK server unreachable.")
      {:stop, :normal}
    {:ok, %{"error" => error}} ->
      Logger.error(error["error_msg"])
      {:stop, :normal}
    end
  end

  def get_longpolling_server_params(bot_params) do
    HTTPoison.request(
      :post,
      base_url("messages.getLongPollServer"),
      {
        :form,
        need_pts: 1,
        lp_version: 2,
        access_token: bot_params.provider_params.token,
        v: api_version()},
      @headers,
      Map.get(bot_params, :hackney_opts, []) |> set_timeout(bot_params, :responser)
    )
  end

  #TODO
  defp set_mode(_bot_params) do
    2+           # get media
    32+          # get pts
    128          # get `random_id`
  end

  # This method sets `hackney` timeout params, depends on what is the type of
  # the worker - for poller it's infinty, for sender - normal values
  defp set_timeout(http_opts, bot_params, module) do
    source = case module do
      :receiver -> :poll_timeout
      :responser -> :response_timeout
    end
    http_opts
    |> Keyword.put(:recv_timeout, get_in(bot_params, [:provider_params, source]) || 5000)
    |> Keyword.put(:timeout, get_in(bot_params, [:provider_params, :timeout]) || 8000)
  end

  defmacro __using__(:handler) do
    quote location: :keep do
      use Agala.Provider.Vk.Helpers.Common
      alias Agala.Provider.Vk.Helpers.{
        Messages,
        Users,
        Photos,
        Docs
      }
    end
  end
end
