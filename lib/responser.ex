defmodule Agala.Provider.Vk.Responser do
  use Agala.Bot.Responser

  defp create_body(%Agala.Conn{response: %{payload: %{body: body}}}, bot_params) when is_map(body) do
    {
      :form,
      body
      |> Map.put(:v, Agala.Provider.Vk.api_version())
      |> Map.put(:access_token, bot_params.provider_params.token)
      |> Enum.into(Keyword.new)
    }
  end
  defp create_body(_, _bot_params) do
    Logger.debug(fn ->
      """
      Your Agala.Conn doesn't have response body value in a propriate form.
      Please, check your response.
      """
    end)
  end

  defp create_url(%Agala.Conn{response: %{payload: %{endpoint: endpoint}}}) do
    Agala.Provider.Vk.base_url(endpoint)
  end

  @doc """
  Main entry point method. Process the response
  """
  def response(conn, bot_params) do
    HTTPoison.request(
      conn.response.method,
      create_url(conn),
      create_body(conn, bot_params),
      get_in(conn, [:response, :payload, :headers]) || [],
      get_in(conn, [:response, :payload, :http_opts]) || get_in(bot_params, [:private, :http_opts]) || []
    )
  end
end
