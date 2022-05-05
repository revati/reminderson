defmodule Infrastructure.Twitter.Parser do
  require Logger

  # @eixsting_atoms [:period_length, :period_type]
  @time Time.new!(9, 0, 0)

  @characters [
    {"ā", "a"},
    {"č", "č"},
    {"ē", "e"},
    {"ģ", "g"},
    {"ī", "i"},
    {"ķ", "k"},
    {"ļ", "l"},
    {"ņ", "n"},
    {"š", "s"},
    {"ū", "u"},
    {"ž", "z"}
  ]

  @parsers [
    {:exact_date, ~r/(?<day>\d{1,2})\.(?<month>\d{1,2})(\.(?<year>\d{2}(\d{2})?))?/},
    {:diff_date,
     ~r/pec ((?<period_length>\d+) )?(?<period_type>(dienas|dienam|diena|nedelas|nedelam|nedela|menesis|menesa|menesiem|gads|gada|gadiem))/}
  ]

  def parse(text, _relative_date) when text in [nil, ""] do
    {:ok, nil, "", []}
  end

  def parse(text, relative_date) do
    text = normalize_text(text)

    @parsers
    |> Enum.reduce_while(false, fn {name, regex}, false ->
      case Regex.named_captures(regex, text <> " ") do
        %{} = results ->
          {:ok, date} = apply(__MODULE__, name, [results, relative_date])
          {reminder_text, tags} = prepare_reminder_text(regex, text)
          {:halt, {:ok, date, reminder_text, tags}}

        nil ->
          {:cont, false}
      end
    end)
    |> then(fn
      false ->
        {reminder_text, tags} = prepare_reminder_text(text)
        {:ok, nil, reminder_text, tags}

      {:ok, datetime, reminder_text, tags} ->
        {:ok, datetime, reminder_text, tags}
    end)
  end

  defp prepare_reminder_text(text) do
    text
    |> String.split(" ")
    |> Enum.reject(&(&1 == "" || String.starts_with?(&1, "@")))
    |> Enum.group_by(&String.starts_with?(&1, "#"))
    |> Enum.into(%{true: [], false: []})
    |> then(fn %{true: tags, false: text_parts} ->
      {Enum.join(text_parts, " "), Enum.map(tags, &String.replace_leading(&1, "#", ""))}
    end)
  end

  defp prepare_reminder_text(regex, text) do
    regex
    |> Regex.replace(text, "")
    |> prepare_reminder_text()
  end

  def exact_date(%{"day" => _, "month" => _, "year" => ""} = parts, now) do
    parts = normalize_parts(parts)

    year =
      if parts.month < now.month || (parts.month == now.month && parts.day <= now.day),
        do: now.year + 1,
        else: now.year

    DateTime.new(Date.new!(year, parts.month, parts.day), @time, now.timezone)
  end

  def exact_date(%{"day" => _, "month" => _, "year" => _} = parts, now) do
    parts = normalize_parts(parts)
    DateTime.new(Date.new!(parts.year, parts.month, parts.day), @time, now.timezone)
  end

  def diff_date(%{"period_type" => period, "period_length" => ""}, now) do
    diff_date(%{"period_type" => period, "period_length" => "1"}, now)
  end

  def diff_date(%{"period_type" => _, "period_length" => _} = parts, now) do
    %{period_length: length, period_type: type} = normalize_parts(parts)

    {type, length} = if type == :weeks, do: {:days, length * 7}, else: {type, length}

    {:ok,
     now
     |> Timex.shift([{type, length}])
     |> Map.put(:hour, 9)
     |> Map.put(:minute, 0)
     |> Map.put(:second, 0)
     |> Map.put(:microsecond, {0, 0})}
  end

  defp normalize_parts(parts) do
    parts
    |> Enum.reject(fn {_k, v} -> v in ["", nil] end)
    |> Enum.into(%{}, fn {key, value} ->
      {String.to_existing_atom(key), normalize_single_part(key, value)}
    end)
  end

  defp normalize_single_part("year", value) do
    value = if String.length(value) == 2, do: "20#{value}", else: value

    String.to_integer(value)
  end

  defp normalize_single_part(name, value)
       when name in ["day", "month", "period_length"] do
    String.to_integer(value)
  end

  defp normalize_single_part("period_type", value)
       when value in ["diena", "dienas", "dienam"] do
    :days
  end

  defp normalize_single_part("period_type", value)
       when value in ["nedela", "nedelas", "nedelam"] do
    :weeks
  end

  defp normalize_single_part("period_type", value)
       when value in ["menesis", "menesa", "menesiem"] do
    :months
  end

  defp normalize_single_part("period_type", value) when value in ["gads", "gada", "gadiem"] do
    :years
  end

  # defp normalize_text(text) do
  # end

  defp normalize_text(text) do
    Enum.reduce(@characters, text, fn {from, to}, text ->
      String.replace(text, from, to)
    end)
  end
end
