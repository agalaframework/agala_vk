defmodule Agala.Provider.Vk.Chain.Parser do
  def init(_) do
    []
  end

  def call(conn = %Agala.Conn{
    request: request
  }, _opts) do
    conn
    |> Map.put(:request, parse_request(request))
  end

  def parse_request([
    4,
    message_id,
    flags,
    user_id,
    bot_id,
    tree_dots,
    text,
    opts,
    random_id
  ]) do
    %{
      message_id: message_id,
      flags: flags,
      user_id: user_id,
      bot_id: bot_id,
      tree_dots: tree_dots,
      text: text,
      opts: opts,
      random_id: random_id
    }
  end
  def parse_request(unknown_request), do: unknown_request
end
