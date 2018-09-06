defmodule Agala.Provider.Vk.Model.Updates.NewMessage do
  defstruct [
    message_id: nil,
    flags: nil,
    user_id: nil,
    bot_id: nil,
    tree_dots: "",
    text: "",
    opts: %{},
    random_id: nil
  ]
end
