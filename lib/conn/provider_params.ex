defmodule Agala.Provider.Vk.Conn.ProviderParams do
  defstruct [
    token: nil,
    poll_timeout: nil,
    poll_wait: 25,
    response_timeout: nil,
    hackney_opts: Keyword.new
  ]

  @type t :: %Agala.Provider.Vk.Conn.ProviderParams{
    token: String.t,
    poll_timeout: integer | :infinity,
    poll_wait: integer,
    response_timeout: integer | :infinity,
    hackney_opts: Keyword.t
  }

  @behaviour Access
  @doc false
  def fetch(bot_params, key) do
    Map.fetch(bot_params, key)
  end

  @doc false
  def get(structure, key, default \\ nil) do
    Map.get(structure, key, default)
  end

  @doc false
  def get_and_update(term, key, list) do
    Map.get_and_update(term, key, list)
  end

  @doc false
  def pop(term, key) do
    {get(term, key), term}
  end
end
