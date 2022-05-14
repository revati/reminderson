defmodule Infrastructure.Schema do
  use Boundary, top_level?: true, deps: [Infrastructure.Mex], exports: []

  defmacro __using__(_) do
    quote do
      use Infrastructure.Mex
      @primary_key false
      @foreign_key_type Infrastructure.UUID
      @save_fields_options :unsafe_save_all
    end
  end
end
