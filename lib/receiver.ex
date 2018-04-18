defmodule Agala.Provider.Vk.Receiver do
  @moduledoc """
  Main worker module
  """
  @vsn 2
  use Agala.Bot.Receiver
  alias Agala.BotParams

  defp get_updates_url(%BotParams{private: %{
    key: key,
    mode: mode,
    server: server,
    ts: ts,
    wait: wait
  }}) do
    "https://"<>server<>
    "?act=a_check&key="<>key<>
    "&ts="<>Integer.to_string(ts)<>
    "&wait="<>Integer.to_string(wait)<>
    "&mode="<>Integer.to_string(mode)<>
    "&version"<>Integer.to_string(@vsn)
  end

  defp get_updates_options(%BotParams{private: %{http_opts: http_opts}}), do: http_opts

  def get_updates(notify_with, bot_params = %BotParams{}) do
    HTTPoison.get(
      get_updates_url(bot_params),            # url
      [{"Content-Type", "application/json"}], # headers
      get_updates_options(bot_params)         # opts
    )
    |> parse_body
    |> resolve_updates(notify_with, bot_params)
  end

  ### Known errors
  ### -----------------------------------------------------------------------------

  ### Corrupted history
  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: _,
        body: %{"ts" => ts, "failed" => 1}
      }
    },
    _,
    bot_params
  ) do
    Logger.debug "Event history is corrupted, resending with new timestamp..."
    Agala.set(bot_params, :poll_server_ts, ts)
    bot_params |> put_in([:private, :ts], ts)
  end

  ### Key is expired
  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: _,
        body: %{"failed" => 2}
      }
    },
    _,
    bot_params
  ) do
    Logger.debug "Key's active period expired. Retrieving new key..."
    bot_params |> put_in([:common, :restart], true)
  end

  ### User information is lost
  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: _,
        body: %{"failed" => 3}
      }
    },
    _,
    bot_params
  ) do
    Logger.debug "User information was lost. Retrieving new key and timestamp..."
    bot_params |> put_in([:common, :restart], true)
  end

  ### Version invalid
  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: _,
        body: %{"failed" => 4}
      }
    },
    _,
    bot_params
  ) do
    Logger.debug "Invalid version number was passed. Restarting..."
    bot_params |> put_in([:common, :restart], true)
  end
  ### -----------------------------------------------------------------------------

  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ts" => ts, "updates" => []}
      }
    },
    _,
    bot_params
  ) do
    # We are seting ts to the safe place in order to get if this poller will
    # be restarted
    Agala.set(bot_params, :poll_server_ts, ts)
    bot_params |> put_in([:private, :ts], ts)
  end


  defp resolve_updates(
    {
      :error,
      %HTTPoison.Error{
        id: nil,
        reason: :timeout
      }
    },
    _,
    bot_params
  ) do
    # This is just failed long polling, simply restart
    Logger.debug("Long polling request ended with timeout, resend to poll")
    bot_params
  end

  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ts" => ts, "updates" => updates}
      }
    },
    notify_with,
    bot_params
  ) do
    Logger.debug fn -> "Response body is:\n #{inspect updates}" end
    updates
    |> Enum.each(notify_with)
    Agala.set(bot_params, :poll_server_ts, ts)
    bot_params |> put_in([:private, :ts], ts)
  end
  defp resolve_updates({:ok, %HTTPoison.Response{status_code: status_code, body: body}}, _, bot_params) do
    Logger.warn("HTTP response ended with status code #{inspect status_code}\nand body:\n#{inspect body}")
    bot_params
  end
  defp resolve_updates({:error, err}, _, bot_params) do
    Logger.warn("#{inspect err}")
    bot_params
  end

  defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}) do
    {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}
  end
  defp parse_body(default), do: default
end
