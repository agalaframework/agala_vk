defmodule Agala.Provider.Vk.Helpers.Common do
  defmacro __using__(_opts) do
    quote location: :keep do
      @headers [{"Content-Type", "application/json"}]
      @multipart_headers [{"Content-Type", "multipart/form-data"}]

      def send_file_to_url(url, params, opts \\ %{}) do
        HTTPoison.post(
          url,
          create_body_multipart(params, opts),
          @multipart_headers,
          Map.get(opts, :http_opts, [])
        )
      end

      defp create_body(map, opts \\ []) do
        Map.merge(map, Enum.into(opts, %{}), fn _, v1, _ -> v1 end)
      end

      defp create_body_multipart(map, opts \\ []) do
        multipart =
          create_body(map, opts)
          |> Enum.map(fn
            {:file, file} -> {:file, file, []}
            {key, value} -> {to_string(key), to_string(value)}
          end)

        {:multipart, multipart}
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
