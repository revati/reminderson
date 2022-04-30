defmodule Infrastructure do
  use Boundary, deps: [Infrastructure.Router, CRUD, Reminder], exports: [Dispatcher]
end
