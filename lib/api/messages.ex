defmodule Agala.Provider.Vk.Helpers.Messages do
  use Agala.Provider.Vk.Helpers.Common
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
  def send(conn, user_id, params) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "messages.send",
        body: create_body(params, user_id: user_id, random_id: random_id(user_id)),
        headers: @headers
      }
    })
  end

  def mark_as_read(conn, peer_id, start_message_id) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "messages.markAsRead",
        body: create_body(%{
          peer_id: peer_id,
          start_message_id: start_message_id
        }),
        headers: @headers
      }
    })
  end

  def set_activity(conn, user_id, type, peer_id) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "messages.setActivity",
        body: create_body(%{
          user_id: user_id,
          type: type,
          peer_id: peer_id
        }),
        headers: @headers
      }
    })
  end

  def get_by_id(conn, message_ids) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "messages.getById",
        body: create_body(%{
          message_ids: message_ids
        }),
        headers: @headers
      }
    })
  end
end
