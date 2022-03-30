defmodule RewardappWeb.GrantView do
  use RewardappWeb, :view

  def currentUser(conn) do
    person = Plug.Conn.get_session(conn, :userInfo)
    post = Rewardapp.Repo.get!(RewardappWeb.User, person.id)
  end

  def currentMonth(conn) do
    date = Date.utc_today()
    month = date.month
    IO.inspect(month)

    case month do
      1 ->
        month = "january"
      2 ->
        month = "february"
      3 ->
        month = "march"
      4 ->
        month = "april"
      5 ->
        month = "may"
      6 ->
        month = "june"
      7 ->
        month = "july"
      8 ->
        month = "august"
      9 ->
        month = "september"
      10 ->
        month = "october"
      11 ->
        month = "november"
      12 ->
        month = "december"
    end

  end

end
