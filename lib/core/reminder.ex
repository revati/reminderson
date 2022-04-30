defmodule Reminder do
  use Boundary,
    exports: {:all, except: [Aggregate]},
    deps: [Core, Twitter, Infrastructure.{Command, Schema}, Mex, MexValidator]
end
