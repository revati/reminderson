defmodule CRUD do
  use Boundary, deps: [Infrastructure.{Command, Schema}, Infrastructure.Mex], exports: :all
end
