[
  import_deps: [:ecto, :phoenix, :commanded, :commanded_ecto_projections],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  export: [
    locals_without_parens: [mex_embedded_schema: 1, mex_field: 2, mex_field: 3]
  ]
]
