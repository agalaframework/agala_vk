defmodule Agala.Provider.Vk.Model.ResponseMessage do
  defstruct [
    :user_id,
    :random_id,
    :peer_id,
    :domain,
    :chat_id,
    :user_ids,
    :message,
    :lat,
    :long,
    :attachment,
    :forward_messages,
    :sticker_id
  ]
end
