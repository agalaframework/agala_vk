defmodule Agala.Provider.Vk.Responser do
  alias Agala.Provider.Vk
  defmacro __using__(_) do
    quote location: :keep do
      require Logger
      @behaviour Agala.Bot.Responser

      defp create_body(conn = %Agala.Conn{response: %{payload: %{body: body}}}) when is_map(body) do
        {
          :form,
          body
          |> Map.put(:v, Vk.api_version())
          |> Map.put(:access_token, conn.request_bot_params.provider_params.token)
          |> Enum.into(Keyword.new)
        }
      end
      defp create_body(_) do
        Logger.debug(fn ->
          """
          Your Agala.Conn doesn't have response body value in a propriate form.
          Please, check your response.
          """
        end)
      end

      defp create_url(conn = %Agala.Conn{response: %{payload: %{endpoint: endpoint}}}, bot_params) when is_function(url) do
        Vk.base_url(endpoint)
      end

      @doc """
      Main entry point method. Process the response
      """
      def response(conn, bot_params) do
        HTTPoison.request(
          conn.response.method,
          create_url(conn, bot_params),
          create_body(conn),
          Map.get(conn.response.payload, :headers, []),
          Map.get(conn.response.payload, :http_opts) || Map.get(bot_params.private, :http_opts) || []
        )
      end
    end
  end
end
