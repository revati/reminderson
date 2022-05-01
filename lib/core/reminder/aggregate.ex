defmodule Reminder.Aggregate do
  alias Reminder.Helpers

  defstruct [
    :id,
    :parsed_text,
    :tags,
    :remind_at,
    :ask_reminder_id,
    :ask_reminder_screen_name,
    :reason_id,
    :reason_screen_name,
    :acknowledgement_id,
    :reminder_id
  ]

  def execute(%__MODULE__{id: nil}, %Reminder.RecordTweet{} = command) do
    {:ok, datetime, text, tags} = Twitter.parse(command.text, command.created_at)

    command
    |> Map.from_struct()
    |> Map.put(:tags, tags)
    |> Map.put(:remind_at, datetime)
    |> Map.put(:parsed_text, text)
    |> then(&Helpers.normalize_reason_params/1)
    |> then(&struct(Reminder.TweetRecorded, &1))
  end

  def execute(%__MODULE__{}, %Reminder.RecordTweet{}) do
    {:error, :already_recorded}
  end

  def execute(%__MODULE__{id: nil}, %Reminder.FetchTweetReasonText{}) do
    {:error, :not_found}
  end

  def execute(%__MODULE__{id: id} = aggregate, %Reminder.FetchTweetReasonText{}) do
    case aggregate do
      %{ask_reminder_id: id, reason_id: id} ->
        :ok

      %{reason_id: reason_id} ->
        case Twitter.get_text_by_id(reason_id) do
          {:ok, text} -> %Reminder.ReasonTextFetched{id: id, reason_text: text}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def execute(%__MODULE__{id: nil}, %Reminder.AcknowledgeTweet{}) do
    {:error, :not_found}
  end

  def execute(%__MODULE__{} = a, %Reminder.AcknowledgeTweet{}) do
    with {:ack, nil} <- {:ack, a.acknowledgement_id},
         text <- Helpers.prepare_acknowledgement_text(a),
         {:ok, tweet} <- Twitter.respond_to_tweet(a.ask_reminder_id, text, quote: a.reason_id) do
      %Reminder.TweetAcknowledged{id: a.id, acknowledgement_id: tweet.tweet_id}
    else
      {:ack, _} -> {:ok, :already_acknowledged}
      {:error, reason} -> {:error, reason}
    end
  end

  def execute(%__MODULE__{id: nil}, %Reminder.RemindAboutTweet{}) do
    {:error, :not_found}
  end

  def execute(%__MODULE__{} = a, %Reminder.RemindAboutTweet{}) do
    with {:ack, ack} when not is_nil(ack) <- {:ack, a.acknowledgement_id},
         {:rem, nil} <- {:rem, a.reminder_id},
         text <- Helpers.prepare_reminder_text(a),
         {:ok, tweet} <- Twitter.respond_to_tweet(a.acknowledgement_id, text, quote: a.reason_id) do
      %Reminder.RemindedAboutTweet{id: a.id, reminder_id: tweet.tweet_id}
    else
      {:ack, _} -> {:error, :missing_acknowledgement}
      {:rem, _} -> {:ok, :already_reminded}
      {:error, reason} -> {:error, reason}
    end
  end

  def apply(%__MODULE__{id: nil} = aggregate, %Reminder.TweetRecorded{} = event) do
    %{
      aggregate
      | id: event.id,
        parsed_text: event.parsed_text,
        tags: event.tags,
        remind_at: event.remind_at,
        ask_reminder_id: event.ask_reminder_id,
        ask_reminder_screen_name: event.ask_reminder_screen_name,
        reason_id: event.reason_id,
        reason_screen_name: event.reason_screen_name
    }
  end

  def apply(%__MODULE__{} = aggregate, %Reminder.ReasonTextFetched{}) do
    aggregate
  end

  def apply(%__MODULE__{} = aggregate, %Reminder.TweetAcknowledged{} = event) do
    %{aggregate | acknowledgement_id: event.acknowledgement_id}
  end

  def apply(%__MODULE__{} = aggregate, %Reminder.RemindedAboutTweet{} = event) do
    %{aggregate | reminder_id: event.reminder_id}
  end
end
