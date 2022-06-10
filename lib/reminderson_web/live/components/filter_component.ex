defmodule RemindersonWeb.FilterComponent do
  use RemindersonWeb, :live_component
  alias Reminderson.Reminders

  defmodule Form do
    use Infrastructure.Schema
    alias Ecto.Changeset

    mex_embedded_schema do
      mex_field(:ask_reminder_screen_name, :string)
      mex_field(:reason_screen_name, :string)
      mex_field(:tags, {:array, :string})
    end

    def changeset(%__MODULE__{} = schema \\ %__MODULE__{}, params) do
      Infrastructure.Mex.Validator.validate(schema, normalize_from_url(params), [])
    end

    def to_params(%Changeset{} = changeset) do
      changeset
      |> Changeset.apply_changes()
      |> Map.from_struct()
      |> remove_empty()
    end

    def to_changes(%Changeset{} = changeset) do
      changeset |> Map.get(:changes) |> remove_empty()
    end

    defp remove_empty(payload) do
      Enum.filter(payload, fn
        {_key, value} when value in [nil, "", [], [""]] -> false
        _ -> true
      end)
    end

    def normalize_from_url(payload) do
      tags_key = if EnumHelpers.key_type(payload) === :atom, do: :tags, else: "tags"

      Map.update(payload, tags_key, [], fn
        tag when is_binary(tag) -> String.split(tag, ",")
        tags when is_list(tags) -> tags
      end)
    end

    def normalize_to_url(payload) do
      Enum.into(payload, %{}, fn
        {:tags, value} -> {:tags, Enum.join(value, ",")}
        {key, value} -> {key, value}
      end)
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
    changeset = Map.fetch!(assigns, :changeset)
    params = Form.to_params(changeset)

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
      |> Form.to_changes()
      |> Form.normalize_to_url()

    {:noreply, push_redirect(socket, to: socket.assigns.redirect_to.(params))}
  end
end
