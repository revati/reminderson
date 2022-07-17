defmodule Reminder.Helpers do
  def prepare_acknowledgement_text(%Reminder.Aggregate{remind_at: nil} = aggregate) do
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} #{tweet_link} pieglabāšu šo tweetu vēlākam. #{aggregate.id}"
  end

  def prepare_acknowledgement_text(%Reminder.Aggregate{} = aggregate) do
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} #{tweet_link} atgādināšu tev par šo tweetu #{NaiveDateTime.to_string(aggregate.remind_at)}. #{aggregate.id}"
  end

  def prepare_reminder_text(%Reminder.Aggregate{} = aggregate) do
    tags = aggregate.tags |> Enum.map(&"##{&1}") |> Enum.join(" ")
    tweet_link = quote_tweet_link(aggregate)

    "@#{aggregate.ask_reminder_screen_name} #{tweet_link} Atgādinu: #{aggregate.parsed_text} #{tags}. #{aggregate.id}"
  end

  defp quote_tweet_link(%Reminder.Aggregate{} = aggregate) do
    "https://twitter.com/#{aggregate.reason_screen_name}/status/#{Integer.to_string(aggregate.reason_id)}"
  end

  def normalize_reason_params(params) do
    {reason_id, reason_screen_name, reason_text} = extract_reason_params(params)

    params
    |> Map.put(:reason_id, reason_id)
    |> Map.put(:reason_screen_name, reason_screen_name)
    |> Map.put(:reason_text, reason_text)
  end

  defp extract_reason_params(params) do
    cond do
      params.respond_to_id -> {params.respond_to_id, params.respond_to_screen_name, nil}
      params.quote_id -> {params.quote_id, params.quote_screen_name, nil}
      true -> {params.ask_reminder_id, params.ask_reminder_screen_name, params.text}
    end
  end
end
