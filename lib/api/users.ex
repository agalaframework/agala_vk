defmodule Agala.Provider.Vk.Helpers.Users do
  use Agala.Provider.Vk.Helpers.Common

  @doc """
  Params:
  * `user_ids` - list of user id's
  * opts - keyword, which can have next params:
    * `fields` - string with additional fields, separated by comma
    * `name_case` - string with case of the returned name. Available values:
      * "nom"
      * "gen"
      * "dat"
      * "acc"
      * "ins"
      * "abl"
  """
  def get(conn, user_ids, opts \\ []) do
    Map.put(conn, :response, %Agala.Provider.Vk.Conn.Response{
      method: :post,
      payload: %{
        endpoint: "users.get",
        body: create_body(%{
          user_ids: user_ids |> Enum.join(",")
        }, opts),
        headers: @headers
      }
    })
  end
end
