defmodule Infrastructure.Mex do
  use Boundary,
    top_level?: true,
    deps: [Infrastructure.Mutex, Infrastructure.Repo],
    exports: [Validator]

  @field_opts [
    :default,
    :source,
    :autogenerate,
    :read_after_writes,
    :virtual,
    :primary_key,
    :load_in_query,
    :redact,
    :foreign_key,
    :on_replace,
    :defaults,
    :type,
    :where,
    :references,
    :skip_default_validation,
    :values
  ]

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Infrastructure.Mex, only: [mex_embedded_schema: 1, mex_schema: 2]

      Module.register_attribute(__MODULE__, :fields_meta, accumulate: true)
      Module.put_attribute(__MODULE__, :save_fields_options, [])
    end
  end

  defmacro mex_embedded_schema(do: block) do
    quote do
      embedded_schema(do: unquote(execute_body(block)))
    end
  end

  defmacro mex_schema(source, do: block) do
    quote do
      schema(unquote(source), do: unquote(execute_body(block)))
    end
  end

  defp execute_body(block) do
    prelude =
      quote do
        import Infrastructure.Mex, only: [mex_field: 1, mex_field: 2, mex_field: 3]
        unquote(block)
      end

    postlude =
      quote unquote: false do
        fields_meta = __MODULE__ |> Module.get_attribute(:fields_meta) |> Enum.reverse()
        def __schema__(:meta), do: unquote(fields_meta)
      end

    quote do
      unquote(prelude)
      unquote(postlude)
    end
  end

  defmacro mex_field(name, type \\ :string, opts \\ []) do
    quote do
      unquote(save_metadata(name, [type: type] ++ opts))
      field unquote(name), unquote(type), unquote(Keyword.take(opts, @field_opts))
    end
  end

  defmacro mex_has_many(name, queryable, opts \\ []) do
    ex_queryable = expand_alias(queryable, __CALLER__)

    quote do
      unquote(save_metadata(name, [type: ex_queryable] ++ opts))
      has_many unquote(name), unquote(queryable), unquote(opts)
    end
  end

  defmacro mex_has_one(name, queryable, opts \\ []) do
    ex_queryable = expand_alias(queryable, __CALLER__)

    quote do
      unquote(save_metadata(name, [type: ex_queryable] ++ opts))
      has_one unquote(name), unquote(queryable), unquote(opts)
    end
  end

  defmacro mex_belongs_to(name, queryable, opts \\ []) do
    ex_queryable = expand_alias(queryable, __CALLER__)

    quote do
      unquote(save_metadata(name, [type: ex_queryable] ++ opts))
      belongs_to unquote(name), unquote(queryable), unquote(opts)
    end
  end

  defmacro mex_embeds_one(name, queryable, opts \\ []) do
    ex_queryable = expand_alias(queryable, __CALLER__)

    quote do
      unquote(save_metadata(name, [type: ex_queryable] ++ opts))
      embeds_one unquote(name), unquote(queryable), unquote(opts)
    end
  end

  defp save_metadata(name, opts) do
    opts = Macro.escape(opts)

    quote do
      cond do
        @save_fields_options === :unsafe_save_all ->
          @fields_meta {unquote(name), unquote(opts)}

        Enum.count(@save_fields_options) > 0 ->
          @fields_meta {unquote(name), Keyword.take(unquote(opts), @save_fields_options)}
      end
    end
  end

  defp expand_alias({:__aliases__, _, _} = ast, env),
    do: Macro.expand(ast, %{env | function: {:__schema__, 2}})

  defp expand_alias(ast, _env),
    do: ast
end
