defmodule Infrastructure.Command do
  use Boundary, top_level?: true, deps: [Infrastructure.Mex, Infrastructure.Schema], exports: []

  defmacro __using__(_) do
    quote do
      use Infrastructure.Schema

      def changeset(params, context \\ []),
        do: Infrastructure.Mex.Validator.validate(__MODULE__, params, context)

      defoverridable changeset: 1, changeset: 2
    end
  end
end
