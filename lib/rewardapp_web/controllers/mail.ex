defmodule Rewardapp.Email do
  import Bamboo.Email
  import Bamboo.Phoenix

  def rewardEmail(user) do
    base_email()
    |> to(user)
    |> subject("You were granted points!")
    |> text_body("You were granted some points! To check, log into your account!")
  end

  defp base_email() do
    new_email()
    |> from("rewardapp@gmail.com") # Set a default from
    |> put_html_layout({MyApp.LayoutView, "email.html"}) # Set default layout
    |> put_text_layout({MyApp.LayoutView, "email.text"}) # Set default text layout
  end
end
