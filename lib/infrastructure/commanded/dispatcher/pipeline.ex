defmodule Infrastructure.Dispatcher.Pipeline do
  alias Infrastructure.Dispatcher.PipelineExecutor

  defstruct stage: :pipe_through,
            commands: [],
            input: %{},
            output: {},
            assigns: %{},
            error: nil

  @stages [:pipe_through, :response, :error]

  @owerwritable_options [:causation_id, :correlation_id, :metadata]

  @default_options [
    # causation_id: nil,
    # correlation_id: nil,
    # metadata: [],
    returning: :ok,
    consistency: :strong,
    timeout: 5_000
  ]

  def initiate(commands, input, options, session) do
    %__MODULE__{commands: List.wrap(commands)}
    |> with_input(input)
    |> assign(:options, prepare_options(options, session))
  end

  def execute(%__MODULE__{} = pipeline, middlewares) do
    PipelineExecutor.execute(pipeline, middlewares)
  end

  def to_stage(%__MODULE__{} = pipeline, new_stage) when new_stage in @stages do
    %{pipeline | stage: new_stage}
  end

  def with_input(%__MODULE__{} = pipeline, input) do
    %{pipeline | input: Enum.into(input, %{})}
  end

  def with_error(%__MODULE__{error: nil} = pipeline, e) do
    %{pipeline | error: e}
    |> to_stage(:error)
  end

  def assign(%__MODULE__{} = pipeline, values) when is_list(values) do
    Enum.reduce(values, pipeline, fn {key, value}, pipeline -> assign(pipeline, key, value) end)
  end

  def assign(%__MODULE__{} = pipeline, key, value) do
    Map.update!(pipeline, :assigns, fn assigns -> Map.put(assigns, key, value) end)
  end

  def input_for_command(%__MODULE__{} = pipeline, command) do
    Map.merge(pipeline.input, Map.get(pipeline.input, command, %{}))
  end

  def respond(%__MODULE__{} = pipeline, output) do
    %{pipeline | output: output}
  end

  def to_response(%__MODULE__{error: error}) when not is_nil(error) do
    {:error, error}
  end

  def to_response(%__MODULE__{output: output}) when is_list(output) do
    output
    |> Enum.all?(&match?({_, :ok}, &1))
    |> case do
      true -> :ok
      false -> {:ok, output}
    end
  end

  def to_response(%__MODULE__{output: output}) when not is_nil(output) do
    {:ok, output}
  end

  defp prepare_options(options, session) do
    {options, inline_metadata} = Keyword.split(options, @owerwritable_options)

    metadata =
      inline_metadata
      |> Enum.into(%{})
      |> Map.put_new(:session, session)

    @default_options
    |> Keyword.merge(options)
    |> Keyword.put_new(:metadata, metadata)
  end
end
