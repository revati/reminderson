defmodule RemindersonWeb.FilterComponent do
  use RemindersonWeb, :live_component
  alias Reminderson.Reminders

  defmodule Form do
    use Infrastructure.Schema

    mex_embedded_schema do
      mex_field(:ask_reminder_screen_name, :string)
      mex_field(:reason_screen_name, :string)
      mex_field(:tags, {:array, :string})
    end

    def changeset(%__MODULE__{} = schema \\ %__MODULE__{}, params) do
      tags_key = if EnumHelpers.key_type(params) === :atom, do: :tags, else: "tags"

      params =
        Map.update(params, tags_key, [], fn
          tag when is_binary(tag) -> String.split(tag, ",")
          tags when is_list(tags) -> tags
        end)

      Infrastructure.Mex.Validator.validate(schema, params, [])
    end
  end

  def mount(socket) do
    {:ok,
     assign(socket,
       changeset: nil,
       ask_reminder_screen_name_select: [],
       reason_screen_name_select: [],
       tags_select: []
     )}
  end

  def update(assigns, socket) do
    params = Map.get(assigns, :params, %{})
    changeset = Form.changeset(params)

    assigns = [
      ask_reminder_screen_name_select: Reminders.ask_reminder_screen_name_list(params),
      reason_screen_name_select: Reminders.reason_screen_name_list(params),
      tags_select: params |> Reminders.tags_list() |> Enum.map(& &1.tag),
      id: Map.fetch!(assigns, :id),
      changeset: changeset,
      redirect_to: Map.fetch!(assigns, :redirect_to)
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("filter", %{"filter-form" => params}, socket) do
    params =
      params
      |> Form.changeset()
      |> Map.get(:changes)
      |> then(fn
        %{tags: [""]} = params -> Map.drop(params, [:tags])
        %{tags: _tags} = params -> Map.update!(params, :tags, &Enum.join(&1, ","))
        params -> params
      end)

    {:noreply, push_redirect(socket, to: socket.assigns.redirect_to.(params))}
  end
end
