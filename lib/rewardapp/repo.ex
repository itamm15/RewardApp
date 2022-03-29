defmodule Rewardapp.Repo do
  use Ecto.Repo,
    otp_app: :rewardapp,
    adapter: Ecto.Adapters.Postgres
end
