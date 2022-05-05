defmodule Reminder do
  use Boundary,
    exports: {:all, except: [Aggregate]},
    deps: [
      Infrastructure,
      Infrastructure.{Command, Oban, Repo, Schema, Twitter},
      Mex,
      MexValidator
    ]
end
