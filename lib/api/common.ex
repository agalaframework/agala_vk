defmodule Agala.Provider.Vk.Helpers.Common do
  defmacro __using__(_opts) do
    quote location: :keep do
      @headers [{"Content-Type", "application/json"}]

      defp create_body(map, opts) do
        Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
      end

      defp random_id(user_id) do
        :erlang.term_to_binary({
          user_id,
          DateTime.utc_now
        })
        |> :erlang.md5
        |> Base.encode16
        |> String.replace(~r/[ABCDEF]/, "")
        |> Integer.parse
        |> elem(0)
      end
    end
  end
end
