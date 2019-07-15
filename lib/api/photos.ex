defmodule Agala.Provider.Vk.Helpers.Photos do
  @moduledoc "Contain methods for interactions with photos."

  use Agala.Provider.Vk.Helpers.Common

  @doc """
  Params: [
    peer_id
  ]
  """
  def get_messages_upload_server(conn, peer_id) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "photos.getMessagesUploadServer",
        body: create_body(%{peer_id: peer_id}),
        headers: @headers
      }
    })
  end

  @doc """
  Params: [
    photo
    server
    hash
  ]
  """
  def save(conn, %{"photo" => photo, "server" => server, "hash" => hash}) do
    save(conn, %{photo: photo, server: server, hash: hash})
  end

  def save(conn, %{photo: _photo, server: _server, hash: _hash} = params) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "photos.saveMessagesPhoto",
        body: create_body(params),
        headers: @headers
      }
    })
  end
end
