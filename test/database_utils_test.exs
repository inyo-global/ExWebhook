defmodule ExWebhook.DatabaseUtilsTest do
  alias ExWebhook.DatabaseUtils
  alias ExWebhook.Schema.Webhook
  import Ecto.Query

  import ExUnit.CaptureLog
  require Logger

  use ExUnit.Case, async: false

  defmodule Test.Repo do
    use Ecto.Repo,
      otp_app: :webhook,
      adapter: Ecto.Adapters.Postgres
  end

  test "When databse exit with no connection, then catch and return :connection_error" do
    # just to not polute the console with connection_refused
    capture_log(fn ->
      {:ok, _pid} =
        start_supervised(
          {Test.Repo, [url: "postgresql://localhost:1234/postgres"]},
          restart: :transient
        )

      assert {:connection_error, %DBConnection.ConnectionError{}} =
               DatabaseUtils.safe_call(fn ->
                 query =
                   from(w in Webhook,
                     select: w
                   )

                 Test.Repo.all(query)
               end)
    end)
  end
end
