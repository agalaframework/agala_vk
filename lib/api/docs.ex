defmodule Agala.Provider.Vk.Helpers.Docs do
  @moduledoc "Contain methods for interactions with docs."

  use Agala.Provider.Vk.Helpers.Common

  require Logger

  @doc """
  Params: [
    peer_id
  ]
  """
  def get_messages_upload_server(conn, peer_id) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "docs.getMessagesUploadServer",
        body: create_body(%{peer_id: peer_id}),
        headers: @headers
      }
    })
  end

  # @doc """
  # Params: [
  #   file
  #   title
  #   tags
  # ]
  # """
  def save(conn, %{file: _file} = params) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "docs.save",
        body: create_body(params),
        headers: @headers
      }
    })
  end

  def save(conn, %{"file" => file} = params) do
    save(conn, Map.put(params, :file, file))
  end
end
