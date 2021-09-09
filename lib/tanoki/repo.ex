defmodule Tanoki.Repo do
  use Ecto.Repo,
    otp_app: :tanoki,
    adapter: Ecto.Adapters.Postgres
end
