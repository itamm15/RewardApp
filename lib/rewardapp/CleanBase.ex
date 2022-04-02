defmodule Rewardapp.CleanBase do

  def clean do
    IO.puts("Rewardapp.CleanBase, :clean WORKS CORRECTLY")

    #update all points

    Rewardapp.Repo.update_all(RewardappWeb.User, set: [points: 0])

    #value = Rewardapp.Repo.get(RewardappWeb.User, 2)
    #IO.inspect(value)

    IO.puts("Updated points")

  end
end
