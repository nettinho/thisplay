defmodule Thisplay.Repo do
  use Ecto.Repo,
    otp_app: :thisplay,
    adapter: Ecto.Adapters.Postgres
end
