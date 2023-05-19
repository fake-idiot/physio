defmodule Physio.Repo do
  use Ecto.Repo,
    otp_app: :physio,
    adapter: Ecto.Adapters.Postgres
end
