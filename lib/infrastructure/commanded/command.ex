defmodule Infrastructure.Command do
  defmacro __using__(_) do
    quote do
      use Infrastructure.Schema

      def changeset(params), do: MexValidator.validate(__MODULE__, params)
      defoverridable changeset: 1
    end
  end
end
