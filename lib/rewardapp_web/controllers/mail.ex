defmodule Rewardapp.Email do
  import Bamboo.Email
  import Bamboo.Phoenix

  def rewardEmail(user, points, sessionUser) do
    base_email()
    |> to(user)
    |> subject("You were granted points from #{sessionUser}!")
    |> text_body("You were granted #{points} points! To check, log into your account!")
  end

  defp base_email() do
    new_email()
    |> from("rewardapp@gmail.com") # Set a default from
  end

end
