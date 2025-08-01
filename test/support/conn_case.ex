defmodule ExWebhook.ConnCase do
  use ExUnit.Case, async: true

  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and particularly
  on the `Plug.Conn` module to build connections.

  You can `use` this module in your own test files.
  """
  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import Plug.Conn
      import Phoenix.ConnTest

      @endpoint ExWebhook.Web.Endpoint
      @router ExWebhook.Web.Router

      import Ecto.Changeset
      import Ecto.Query

      setup tags do
        conn = Phoenix.ConnTest.build_conn()
        {:ok, conn: conn}
      end
    end
  end
end
