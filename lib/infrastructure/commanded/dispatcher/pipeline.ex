defmodule Infrastructure.Dispatcher.Pipeline do
  alias Infrastructure.Dispatcher.{PipelineExecutor, ResponseUnifier}

  defstruct stage: :pipe_through,
            commands: [],
            data: [],
            options: [],
            multi?: false

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
    %__MODULE__{
      commands: List.wrap(commands),
      data: [raw_input: Enum.into(input, %{})],
      multi?: is_list(commands),
      options: prepare_options(options, session)
    }
  end

  def execute(%__MODULE__{} = pipeline, middlewares) do
    PipelineExecutor.execute(pipeline, middlewares)
  end

  def halt_as_error(%__MODULE__{} = pipeline) do
    %{pipeline | stage: :error}
  end

  def halt_as_success(%__MODULE__{} = pipeline) do
    %{pipeline | stage: :response}
  end

  def with_data_for_command(%__MODULE__{} = pipeline, command, input) do
    Map.update!(pipeline, :data, fn data ->
      Keyword.put(data, command, input)
    end)
  end

  def to_response(%__MODULE__{} = pipeline) do
    ResponseUnifier.normalize(pipeline)
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
