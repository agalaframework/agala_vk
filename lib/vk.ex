defmodule Agala.Provider.Vk do
  require Logger
  @moduledoc """
  Module providing adapter for Vk
  """
  @headers [{"Content-Type", "application/json"}]

  def base_url(method_name) do
    "https://api.vk.com/method/" <> method_name
  end

  def init(bot_params, module) do
    bot_params = Map.put(bot_params, :private, %{
      http_opts: Keyword.new
                 |> set_proxy(bot_params)
                 |> set_timeout(bot_params, module),
      wait: get_in(bot_params, [:provider_params, :poll_wait]) || 25,
      mode: set_mode(bot_params)
    })
    with {:ok, %HTTPoison.Response{body: body}} <- get_longpolling_server_params(bot_params),
         {:ok, %{"response" => server_params}} <- Poison.decode(body)
    do
      {:ok, bot_params
        |> put_in([:private, :key], server_params["key"])
        |> put_in([:private, :server], server_params["server"])
        # If server was corrupted, we dont want to lose updates so we shift ts a bit back
        |> put_in([:private, :ts], Agala.get(bot_params, :poll_server_ts) || server_params["ts"])
        |> put_in([:private, :pts], server_params["pts"])
      }
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
      {:form, need_pts: 1, lp_version: 2, access_token: bot_params.provider_params.token, v: "5.67"},
      @headers,
      Keyword.new |> set_proxy(bot_params) |> set_timeout(bot_params, :responser)
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
  # Populates HTTPoison options with proxy configuration from bot config.
  defp set_proxy(http_opts, bot_params) do
    resolve_proxy(http_opts,
      get_in(bot_params, [:provider_params, :proxy_url]),
      get_in(bot_params, [:provider_params, :proxy_user]),
      get_in(bot_params, [:provider_params, :proxy_password])
    )
  end
  # Sets valid proxy opts depends on given config params
  defp resolve_proxy(opts, nil, _user, _password), do: opts
  defp resolve_proxy(opts, proxy, nil, nil), do: opts |> Keyword.put(:proxy, proxy)
  defp resolve_proxy(opts, proxy, proxy_user, proxy_password) do
    opts
    |> Keyword.put(:proxy, proxy)
    |> Keyword.put(:proxy_auth, {proxy_user, proxy_password})
  end
end
