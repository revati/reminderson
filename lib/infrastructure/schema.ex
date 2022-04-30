defmodule Infrastructure.Schema do
  defmacro __using__(_) do
    quote do
      use Mex
      @primary_key false
      @foreign_key_type Infrastructure.UUID
      @save_fields_options :unsafe_save_all
    end
  end
end
