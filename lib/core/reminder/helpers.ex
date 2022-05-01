defmodule Reminder.Helpers do
  def prepare_acknowledgement_text(%Reminder.Aggregate{remind_at: nil} = aggregate) do
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} pieglabāšu šo tweetu vēlākam #{tweet_link}. #{aggregate.id}"
  end

  def prepare_acknowledgement_text(%Reminder.Aggregate{} = aggregate) do
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} atgadinasu tev par šo tweetu #{NaiveDateTime.to_string(aggregate.remind_at)} #{tweet_link}. #{aggregate.id}"
  end

  def prepare_reminder_text(%Reminder.Aggregate{} = aggregate) do
    tags = aggregate.tags |> Enum.map(&"##{&1}") |> Enum.join(" ")
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} Atgādinu: #{aggregate.parsed_text} #{tags} #{tweet_link}. #{aggregate.id}"
  end

  defp quote_tweet_link(%Reminder.Aggregate{} = aggregate) do
    "https://twitter.com/#{aggregate.reason_screen_name}/status/#{Integer.to_string(aggregate.reason_id)}"
  end

  def normalize_reason_params(%{reason_id: nil} = params) do
    params
    |> Map.put(:reason_id, params.ask_reminder_id)
    |> Map.put(:reason_screen_name, params.ask_reminder_screen_name)
    |> Map.put(:reason_text, params.text)
  end

  def normalize_reason_params(params) do
    params
  end
end
