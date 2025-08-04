defmodule PrincipalData do
  @moduledoc """
  A struct representing the core data of a principal (user or client)
  extracted from a JWT.

  It includes fields for the subject (`:sub`), authorized party (`:azp`),
  and preferred username (`:preferred_username`).
  """
  defstruct [:sub, :azp, :preferred_username]
end
