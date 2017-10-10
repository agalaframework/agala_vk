defmodule Agala.Provider.Vk.Chain.Parser do
  alias Agala.Provider.Vk.Model.Updates.{NewMessage, ReadOutgoing, DialogTyping}

  def init(_) do
    []
  end

  def call(conn = %Agala.Conn{
    request: request
  }, _opts) do
    conn
    |> Map.put(:request, parse_request(request))
  end

  def parse_request([4,
    message_id,
    flags,
    user_id,
    bot_id,
    tree_dots,
    text,
    opts,
    random_id
  ]) do
    %NewMessage{
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


  def parse_request([7,
    user_id,
    last_vk_message_id
  ]) do
    %ReadOutgoing{
      user_id: user_id,
      last_vk_message_id: last_vk_message_id
    }
  end

  def parse_request([61,
    user_id,
    1
  ]) do
    %DialogTyping{
      user_id: user_id
    }
  end

  def parse_request(unknown_request), do: unknown_request
end
