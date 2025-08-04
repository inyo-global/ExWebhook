defmodule PrincipalDataPlug do
  @moduledoc """
  A plug for extracting and assigning principal data from a request's
  authorization token.

  It expects a JWT in the "Bearer" token format. If a valid token is
  found, it assigns a `PrincipalData` struct to the connection.
  Otherwise, it assigns a default `PrincipalData` struct.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    auth_header = get_req_header(conn, "authorization")

    with ["Bearer " <> token] <- auth_header,
         {:ok, claims} <- Joken.peek_claims(token) do
      principal_data = %PrincipalData{
        sub: Map.get(claims, "sub"),
        azp: Map.get(claims, "azp"),
        preferred_username: Map.get(claims, "preferred_username")
      }

      assign(conn, :principal_data, principal_data)
    else
      _ ->
        assign(conn, :principal_data, %PrincipalData{
          sub: "36583e16-e77b-4c58-b1ac-008322017b0f",
          azp: "d4d6ac8f-9569-4e4d-b795-8eab590c5be0",
          preferred_username: "unknown"
        })
    end
  end
end
