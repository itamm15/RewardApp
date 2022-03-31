defmodule RewardappWeb.GrantController do
  use RewardappWeb, :controller
  import Ecto.Query

  def main(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    awards = Rewardapp.Repo.all(Rewardapp.Award)
    IO.inspect(params)
    IO.puts("I AM IN MAIN +++++ ")
    IO.inspect(Plug.Conn.get_session(conn, :userInfo))

    #person = Plug.Conn.get_session(conn, :userInfo)
    #IO.inspect(person)

    render(conn, "start.html", changeSet: changeSet, users: users, awards: awards)
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
      |> Plug.Conn.put_session(:admin, value)
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
        |> redirect(to: Routes.grant_path(conn, :index), users: users, changeSet: changeSet)
      _ ->
        conn
        |> Plug.Conn.put_session(:userInfo, userSpec)
        |> put_flash(:info, "Logged in")
        |> redirect(to: Routes.grant_path(conn, :main), users: users, changeSet: changeSet)
    end

  end

  def add(conn, %{"user" => userID}) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    IO.puts("I am in add ++++++++")
    #IO.inspect(params)
    IO.inspect(userID)

    render(conn, "add.html", changeSet: changeSet, users: users, userID: userID)
  end

  def update(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    IO.puts("I am in update function +++++")
    IO.inspect(params)
    user = params["user"]
    IO.inspect(user)
    points = String.to_integer(user["points"])
    IO.inspect(points)

    id = String.to_integer(params["id"])
    IO.inspect(id)

    #GETTING USER INFO FROM SESSION, TO TAKE VALUES TO UPDATE

    sessionUser = Plug.Conn.get_session(conn, :userInfo)
    IO.inspect(sessionUser)
    currentMonth = currentMonth(conn)
    IO.inspect(currentMonth)


    post = Rewardapp.Repo.get!(RewardappWeb.User, sessionUser.id)
    IO.inspect(post)
    userInfo = post
    currentPoints = Map.get(post, String.to_atom(currentMonth))

    IO.inspect(currentPoints)

    #changeSet = RewardappWeb.User.changeset(Rewardapp.User, String.to_atom(currentMonth))

    case result = currentPoints - points do
      result when result < 0 ->
        IO.puts("THE RESULT IS LESS THEN ZERO")
        conn
        |> put_flash(:error, "You do not have enough points.")
        |> redirect(to: Routes.grant_path(conn, :add, %{"user" => id}))
      result when result >= 0 ->
        IO.puts("THE RESULT IS GREATER OR EQUAL ZERO")


        # LOGGED USER DATA UPDATE

        case Rewardapp.Repo.update(Ecto.Changeset.change(post, %{String.to_atom(currentMonth) => currentPoints - points})) do
          {:ok, _struct} ->

            # CHOOSEN USER DATA UPDATE
            postC = Rewardapp.Repo.get!(RewardappWeb.User, id)
            previousPoints = postC.points
            userrName = postC.name
            userEmail = postC.mail
            IO.inspect(points)

            case Rewardapp.Repo.update(Ecto.Changeset.change(postC, %{:points => previousPoints + points})) do
              {:ok, _struct } ->

                #IF POINTS WERE ADD TO BOTH USERS
                #I CAN ADD TO REWARDS TABLE INFORMATION
                #userg - user, that gave points
                #userr - user, that received points
                #points - number of points, that was given

                case Rewardapp.Repo.insert(%Rewardapp.Award{:userg => sessionUser.name, :userr => userrName, :points => points, :userrID => id, :usergID => sessionUser.id}) do
                  {:ok, _struct} ->

                    #ALL STATEMENTS ARE CORRECT, SO EMAIL MAY BE SENT
                    Rewardapp.Email.rewardEmail(userEmail)
                    conn
                    |> put_flash(:info, "Added points")
                    |> Plug.Conn.delete_session(:userInfo)
                    |> Plug.Conn.put_session(:userInfo, userInfo)
                    |> redirect(to: Routes.grant_path(conn, :main))
                  {:error, _params} ->
                    conn
                    |> put_flash(:info, "There was some error during saving to database")
                    |> redirect(to: Routes.grant_path(conn, :main))
                end
              {:error, _params} ->
                  conn
                  |> put_flash(:info, "There was some error during saving to database")
                  |> redirect(to: Routes.grant_path(conn, :main))
            end

          {:error, _params} ->
            conn
            |> put_flash(:info, "There was some error during saving to database")
            |> redirect(to: Routes.grant_path(conn, :main))
        end
    end

    render(conn, "start.html", changeSet: changeSet, users: users)
  end

  #ADMIN FUNCTION

  def admin(conn, params) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    awards = Rewardapp.Repo.all(Rewardapp.Award)
    render(conn, "admin.html", changeSet: changeSet, users: users, awards: awards)
  end

  def delete(conn, %{"id" => rewardID}) do

    IO.puts("delete function +++++")

    #GET INFO FROM awards

    IO.inspect(rewardID)
    post = Rewardapp.Repo.get!(Rewardapp.Award, rewardID)
    #userg = post.userg
    #usergID = post.usergID
    #userr = post.userr
    userrID = post.userrID
    pointsPost = post.points
    #IO.inspect(userg)
    #IO.inspect(userr)
    #IO.inspect(points)
    #IO.inspect(usergID)
    #IO.inspect(userrID)


    currentMonth = currentMonth(conn)

    case Rewardapp.Repo.delete(post) do
      {:ok, _struct} ->

        #Give back points to userg
        post = Rewardapp.Repo.get!(RewardappWeb.User, post.usergID)
        currentPoints = Map.get(post, String.to_atom(currentMonth))
        post = Ecto.Changeset.change(post, %{String.to_atom(currentMonth) => pointsPost + currentPoints})

        case Rewardapp.Repo.update(post) do
          {:ok, _struct} ->

            #Take back points from userr

            postr = Rewardapp.Repo.get!(RewardappWeb.User, userrID)
            currentPoints = Map.get(postr, :points)
            postr = Ecto.Changeset.change(postr, %{:points => currentPoints - pointsPost})

            case Rewardapp.Repo.update(postr) do
            {:ok, _params} ->
              conn
              |> put_flash(:info, "Deleted reward")
              |> redirect(to: Routes.grant_path(conn, :admin))
            {:error, params} ->
              IO.inspect(params)
              conn
              |> put_flash(:error, "Error while deleting")
              |> redirect(to: Routes.grant_path(conn, :admin))
            end
            {:error, params} ->
              IO.inspect(params)
              conn
              |> put_flash(:error, "Error while deleting")
              |> redirect(to: Routes.grant_path(conn, :admin))
        end
      {:error, params} ->
        IO.inspect(params)
        conn
        |> put_flash(:error, "Error while deleting")
        |> redirect(to: Routes.grant_path(conn, :admin))
    end
  end

 #CURRENT DATA

 def currentMonth(conn) do
  date = Date.utc_today()
  month = date.month
  IO.inspect(month)

  case month do
    1 -> "january"
    2 -> "february"
    3 -> "march"
    4 -> "april"
    5 -> "may"
    6 -> "june"
    7 ->  "july"
    8 -> "august"
    9 -> "september"
    10 -> "october"
    11 -> "november"
    12 -> "december"
  end
end



end
