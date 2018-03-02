defmodule Agala.Provider.Vk.Helpers.Docs do
  @moduledoc "Contain methods for interactions with docs."

  use Agala.Provider.Vk.Helpers.Common

  alias Agala.Provider.Vk.Conn

  require Logger

  @doc """
  Params: [
    type
    peer_id
  ]
  """
  def get_messages_upload_server(conn, params, opts \\ []) do
    Map.put(conn, :response, %Conn.Response{
      method: :post,
      payload: %{
        endpoint: "docs.getMessagesUploadServer",
        body: create_body(params, opts),
        headers: @headers
      }
    })
  end

  @doc """
  Params: [
    file
    title
    tags
  ]
  """
  def save(conn, params, opts \\ [])
  def save(conn, %{file: file} = params, opts) do
    perform_save(conn, params, opts)
  end

  def save(conn, %{"file" => file} = params, opts) do
    perform_save(conn, params, opts)
  end

  def save(conn, params, opts) do
    Logger.error(fn -> "You must pass url in params. Given params: #{inspect(params)}." end)
    conn
  end

  defp perform_save(conn, params, opts) do
    Map.put(conn, :response, %Conn.Response{
      method: :post,
      payload: %{
        endpoint: "docs.save",
        body: create_body(params, opts),
        headers: @headers
      }
    })
  end
end
