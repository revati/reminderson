defmodule Reminder.Reminder do
  use Infrastructure.Schema

  mex_schema "core_reminders_state" do
    mex_field(:id, :binary_id, validation: :required)
    mex_field(:ask_reminder_id, :integer, validation: :required)
    mex_field(:reason_id, :integer, validation: :required)
    mex_field(:acknowledgement_id, :integer, validation: :required)
    mex_field(:reminder_id, :integer, validation: :required)
  end

  def recorded_changeset(%__MODULE__{} = schema \\ %__MODULE__{}, changes) do
    MexValidator.validate(schema, changes, except: [:acknowledgement_id, :reminder_id])
  end

  def acknowledgement_changeset(%__MODULE__{} = schema \\ %__MODULE__{}, changes) do
    MexValidator.validate(schema, changes, only: [:acknowledgement_id])
  end

  def reminded_changeset(%__MODULE__{} = schema \\ %__MODULE__{}, changes) do
    MexValidator.validate(schema, changes, only: [:reminder_id])
  end
end
