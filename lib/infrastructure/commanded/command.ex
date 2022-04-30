defmodule Infrastructure.Command do
  use Boundary, top_level?: true, deps: [Mex, MexValidator, Infrastructure.Schema], exports: []

  defmacro __using__(_) do
    quote do
      use Infrastructure.Schema

      def changeset(params), do: MexValidator.validate(__MODULE__, params)
      defoverridable changeset: 1
    end
  end
end
