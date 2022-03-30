defmodule RewardappWeb.GrantController do
  use RewardappWeb, :controller
  import Ecto.Query

  def main(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    IO.inspect(params)
    IO.puts("I AM IN MAIN +++++ ")
    IO.inspect(Plug.Conn.get_session(conn, :userInfo))

    #person = Plug.Conn.get_session(conn, :userInfo)
    #IO.inspect(person)

    render(conn, "start.html", changeSet: changeSet, users: users)
  end

  def admin(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    render(conn, "admin.html", changeSet: changeSet, users: users)
  end

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    render(conn, "index.html", changeSet: changeSet)
  end

  def login(conn, %{"user" => userp}) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, userp)
    #IO.inspect(userp)
    users = Rewardapp.Repo.all(RewardappWeb.User)
    #IO.inspect(changeSet)

    #VALIDATION, IF GIVEN USER BELONGS TO DATABASE

    value = userp["user"]
    IO.inspect(value)
    if value == "admin" do
      conn
      |> put_flash(:info, "Logged as admin")
      |> redirect(to: Routes.grant_path(conn, :admin), users: users, changeSet: changeSet)
    end

    #map of lists
    listOfUsers = Rewardapp.Repo.all(RewardappWeb.User)

    IO.inspect(Enum.find(listOfUsers, fn x -> x.name == value end))

    userSpec = Enum.find(listOfUsers, fn x -> x.name == value end)
    #IO.puts("+++++")
    #IO.inspect(userSpec.name)
    #IO.inspect(userSpec.id)
    #IO.puts("+++++")

    case userSpec do
      nil ->
        conn
        |> put_flash(:error, "Could not find the user")
        #render(conn, "index.html", users: users, changeSet: changeSet)
        |> redirect(to: Routes.grant_path(conn, :index), users: users, changeSet: changeSet)
      _ ->
        conn
        |> Plug.Conn.put_session(:userInfo, userSpec)
        |> put_flash(:info, "Logged in")
        #render(conn, "start.html", changeSet: changeSet, users: users, userp: userp)
        #Old fashion version
        #|> redirect(to: Routes.grant_path(conn, :main, userp: value), users: users, changeSet: changeSet)
        |> redirect(to: Routes.grant_path(conn, :main), users: users, changeSet: changeSet)
    end

  end

  def add(conn, %{"user" => userID}) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    #IO.puts("++++++++")
    #IO.inspect(params)
    IO.inspect(userID)


    render(conn, "add.html", changeSet: changeSet, users: users, userID: userID)
  end

end
