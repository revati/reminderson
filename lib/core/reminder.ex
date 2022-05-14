defmodule Reminder do
  use Boundary,
    exports: {:all, except: [Aggregate]},
    deps: [
      Infrastructure,
      Infrastructure.{Command, Mex, Oban, Repo, Schema, Twitter}
    ]
end
