defmodule Agala.Provider.Vk.Helpers.Common do
  defmacro __using__(_opts) do
    quote location: :keep do
      require Logger
      @headers [{"Content-Type", "application/json"}]
      @api_version "5.62"

      defp create_body(map, opts \\ []) do
        Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
      end

      defp random_id(user_id) do
        :erlang.term_to_binary({
          user_id,
          DateTime.utc_now()
        })
        |> :erlang.md5()
        |> Base.encode16()
        |> String.replace(~r/[ABCDEF]/, "")
        |> Integer.parse()
        |> elem(0)
      end

      defp base_url(method_name) do
        "https://api.vk.com/method/" <> method_name
      end

      defp body_encode(body, bot_params)
           when is_map(body) do
        {
          :form,
          body
          |> Map.put(:v, @api_version)
          |> Map.put(:access_token, bot_params.provider_params.token)
          |> Enum.into(Keyword.new())
        }
      end

      defp body_encode(_, _bot_params) do
        Logger.debug(fn ->
          """
          Your Agala.Conn doesn't have response body value in a propriate form.
          Please, check your response.
          """
        end)
      end

      defp bootstrap(bot) do
        case bot.config() do
          {:ok, bot_params} ->
            {:ok,
             Map.put(bot_params, :private, %{
               http_opts:
                 (bot_params.provider_params[:hackney_opts] || [])
                 |> Keyword.put(
                   :recv_timeout,
                   get_in(bot_params, [:provider_params, :response_timeout]) || 5000
                 )
                 |> Keyword.put(
                   :timeout,
                   get_in(bot_params, [:provider_params, :timeout]) || 8000
                 )
             })}
        end
      end

      defp perform_request(
             %Agala.Conn{
               responser: bot,
               response: %{method: method, payload: %{endpoint: endpoint, body: body} = payload}
             } = conn
           ) do
        {:ok, bot_params} = bootstrap(bot)

        case HTTPoison.request(
               method,
               base_url(endpoint),
               body_encode(body, bot_params),
               Map.get(payload, :headers) || [],
               Map.get(payload, :http_opts) || Map.get(bot_params.private, :http_opts) || []
             ) do
          {:ok, %HTTPoison.Response{body: body}} -> Jason.decode(body)
          error -> error
        end
      end
    end
  end
end
