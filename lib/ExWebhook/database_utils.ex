defmodule ExWebhook.DatabaseUtils do
  @moduledoc """
  Handle exit and common database erros
  """

  @type connection_error() :: {:connection_error, DBConnection.ConnectionError.t()}
  @type unexpected_error() :: {:unexpected_error, any()}
  @type database_error() :: connection_error() | unexpected_error()

  @spec safe_call(any()) :: {:ok, any()} | database_error()
  def safe_call(function) do
    result = function.()
    {:ok, result}
  catch
    :error, error = %DBConnection.ConnectionError{} ->
      {:connection_error, error}

    :error, error ->
      {:unexpected_error, error}
  end
end
