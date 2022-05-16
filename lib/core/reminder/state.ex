defmodule Reminder.State do
  use Infrastructure.Schema

  mex_schema "core_reminders_state" do
    mex_field(:id, :binary_id, primary_key: true, validation: :required)
    mex_field(:reason_id, :integer, validation: :required)
    mex_field(:ask_reminder_id, :integer, validation: [:required, :unique])
    mex_field(:acknowledgement_id, :integer, validation: [:required, :unique])
    mex_field(:reminder_id, :integer, validation: [:required, :unique])
  end

  def recorded_changeset(changes) do
    Infrastructure.Mex.Validator.validate(%__MODULE__{}, changes,
      except: [:acknowledgement_id, :reminder_id]
    )
  end

  def acknowledgement_changeset(%__MODULE__{} = schema, changes) do
    Infrastructure.Mex.Validator.validate(schema, changes, only: [:acknowledgement_id])
  end

  def reminded_changeset(%__MODULE__{} = schema, changes) do
    Infrastructure.Mex.Validator.validate(schema, changes, only: [:reminder_id])
  end
end
