defmodule Agala.Provider.Vk.Helpers do
  alias Agala.Provider.Vk
  @headers [{"Content-Type", "application/json"}]
  defp create_body(map, opts) do
    Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
  end

  @doc """
  Params: [
    user_id,
    random_id,
    peer_id,
    domain,
    chat_id,
    user_ids,
    message,
    lat,
    long,
    attachment,
    forward_messages,
    sticker_id,
  ]
  """
  def send_message(conn, name, user_id, message, opts \\ []) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "messages.send",
        body: create_body(%{user_id: user_id, message: message}, opts),
        headers: @headers
      }
    })
    |> Map.put(:responser_name, name)
  end
end
