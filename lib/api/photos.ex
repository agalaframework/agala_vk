defmodule Agala.Provider.Vk.Helpers.Photos do
  @moduledoc "Contain methods for interactions with photos."

  use Agala.Provider.Vk.Helpers.Common

  alias Agala.Provider.Vk.Conn

  @doc """
  Params: [
    peer_id
  ]
  """
  def get_messages_upload_server(conn, params, opts \\ []) do
    Map.put(conn, :response, %Conn.Response{
      method: :post,
      payload: %{
        endpoint: "photos.getMessagesUploadServer",
        body: create_body(params, opts),
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
  def save_messages_photo(conn, params, opts \\ [])
  def save_messages_photo(conn, %{photo: photo, server: server, hash: hash}, opts) do
    perform_save_messages_photo(conn, %{photo: photo, server: server, hash: hash}, opts)
  end

  def save_messages_photo(conn, %{"photo" => photo, "server" => server, "hash" => hash}, opts) do
    perform_save_messages_photo(conn, %{photo: photo, server: server, hash: hash}, opts)
  end

  defp perform_save_messages_photo(conn, params, opts) do
    Map.put(conn, :response, %Conn.Response{
      method: :post,
      payload: %{
        endpoint: "photos.saveMessagesPhoto",
        body: create_body(params, opts),
        headers: @headers
      }
    })
  end

  @doc """
  Prams: [
    photos
    extended
    photo_sizes
  ]
  """
  def get_by_id(conn, params, opts \\ []) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "photos.getById",
        body: create_body(%{
          photos: Map.get(params, :photos, ""),
          extended: safe_boolean_params(Map.get(params, :extended, 0)),
          photo_sizes: safe_boolean_params(Map.get(params, :photo_sizes, 0))
        }, opts),
        headers: @headers
      }
    })
  end

  defp safe_boolean_params(true), do: 1
  defp safe_boolean_params(false), do: 0
  defp safe_boolean_params(param), do: param
end
