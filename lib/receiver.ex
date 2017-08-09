defmodule Agala.Provider.Vk.Receiver do
  @moduledoc """
  Main worker module
  """
  @vsn 2
  use Agala.Bot.PollServer
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

  def get_updates(bot_params = %BotParams{}) do
    HTTPoison.get(
      get_updates_url(bot_params),            # url
      [{"Content-Type", "application/json"}], # headers
      get_updates_options(bot_params)         # opts
    )
    |> parse_body
    |> resolve_updates(bot_params)
  end

  defp resolve_updates(
    {
      :ok,
      %HTTPoison.Response{
        status_code: 200,
        body: %{"ts" => ts, "updates" => []}
      }
    },
    bot_params
  ), do: bot_params |> put_in([:private, :ts], ts)
  defp resolve_updates(
    {
      :error,
      %HTTPoison.Error{
        id: nil,
        reason: :timeout
      }
    },
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
    bot_params
  ) do
    Logger.debug fn -> "Response body is:\n #{inspect(updates)}" end
    updates
    |> Enum.each(&(process_message(&1, bot_params)))
    bot_params |> put_in([:private, :ts], ts)
  end
  defp resolve_updates({:ok, %HTTPoison.Response{status_code: status_code}}, bot_params) do
    Logger.warn("HTTP response ended with status code #{status_code}")
    bot_params
  end
  defp resolve_updates({:error, err}, bot_params) do
    Logger.warn("#{inspect err}")
    bot_params
  end

  defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}) do
    {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}
  end
  defp parse_body(default), do: default

  defp process_message(message, bot_params) do
    # Cast received message to handle bank, there the message
    # will be proceeded throw handlers pipe
    Agala.Bot.Handler.cast_to_handle(
      message,
      bot_params
    )
  end
end
