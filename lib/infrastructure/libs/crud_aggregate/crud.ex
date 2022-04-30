defmodule CRUD do
  use Boundary, deps: [Infrastructure.{Command, Schema}, Mex, MexValidator], exports: :all
end
