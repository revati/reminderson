defmodule TwitterApi do
  def get_text_by_id(id) do
    id
    |> ExTwitter.show()
    |> then(fn
      %ExTwitter.Model.Tweet{text: text} ->
        {:ok, text}
    end)
  end
end
