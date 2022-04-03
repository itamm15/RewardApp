defmodule RewardappWeb.GrantController do
  use RewardappWeb, :controller
  import Ecto.Query

  alias Rewardapp.{Mailer, Email}

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
    if String.equivalent?(value, "admin") do
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
                    Email.rewardEmail(userEmail) |> Mailer.deliver_now()
                    IO.inspect(Rewardapp.Email.rewardEmail(userEmail))
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


  def edit(conn, %{"id" => rewardID}) do
    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)

    award = Rewardapp.Repo.get!(Rewardapp.Award, String.to_integer(rewardID))

    render(conn, "edit.html", changeSet: changeSet, users: users, award: award)

  end

  def adminUpdate(conn, params) do
    IO.puts("adminUpdate function +++++")
    IO.inspect(params)

    changeSet = RewardappWeb.User.changeset(%RewardappWeb.User{}, %{})
    users = Rewardapp.Repo.all(RewardappWeb.User)
    awards = Rewardapp.Repo.all(Rewardapp.Award)

    rewardID = params["id"]
    user = params["user"]
    pointsTmp = user["points"]
    pointsAct = String.to_integer(pointsTmp)

    IO.puts("pointsTmp +++++")
    IO.inspect(user)
    IO.inspect(pointsTmp)
    IO.inspect(pointsAct)
    IO.inspect(rewardID)
    #IO.inspect(points)

    post = Rewardapp.Repo.get!(Rewardapp.Award, rewardID)

    #FIRSTLY, I NEED TO RETURN GIVEN POINTS FROM USERG
    #THEN, TAKE BACK POINTS FROM USERR
    #AND FINALY, I CAN ASSIGN VALUE FROM ADMIN

    #USERG

    usergID = post.usergID
    userrID = post.userrID
    pointsPost = post.points
    currentMonth = currentMonth(conn)

    IO.puts("pointsPost +++++")
    IO.inspect(pointsPost)

    post = Rewardapp.Repo.get!(RewardappWeb.User, usergID)
    currentPoints = Map.get(post, String.to_atom(currentMonth))

    case result = (currentPoints + pointsPost) - pointsAct do
      result when result < 0 ->
        conn
        |> put_flash(:error, "You can not assign that number of points.")
        |> redirect(to: Routes.grant_path(conn, :edit, rewardID))
      result when result >= 0 ->
        post = Rewardapp.Repo.get!(RewardappWeb.User, usergID)
        IO.puts("INSPECT POST OF USER +++++")
        IO.inspect(post)
        IO.inspect(currentPoints)
        usergName = post.name
        post = Ecto.Changeset.change(post, %{String.to_atom(currentMonth) => currentPoints - pointsAct})
        case Rewardapp.Repo.update(post) do
          {:ok, _struct} ->

            # CHOOSEN USER DATA UPDATE
            postC = Rewardapp.Repo.get!(RewardappWeb.User, userrID)
            previousPoints = postC.points
            userrName = postC.name

            case Rewardapp.Repo.update(Ecto.Changeset.change(postC, %{:points => previousPoints + pointsAct})) do
              {:ok, _struct } ->

                case Rewardapp.Repo.insert(%Rewardapp.Award{:userg => usergName, :userr => userrName, :points => pointsAct, :userrID => userrID, :usergID => usergID}) do
                  {:ok, _struct} ->

                    post = Rewardapp.Repo.get!(Rewardapp.Award, rewardID)

                    case Rewardapp.Repo.delete(post) do
                      {:ok, _params} ->
                        #Give back points to userg
                        post = Rewardapp.Repo.get!(RewardappWeb.User, post.usergID)
                        currentPoints = Map.get(post, String.to_atom(currentMonth))
                        post = Ecto.Changeset.change(post, %{String.to_atom(currentMonth) => pointsPost + currentPoints})
                        case Rewardapp.Repo.update(post) do
                          {:ok, _params} ->

                            #Take back points from userr

                            postr = Rewardapp.Repo.get!(RewardappWeb.User, userrID)
                            currentPoints = Map.get(postr, :points)
                            IO.puts("currentPoints ++++++")
                            IO.inspect(currentPoints)
                            IO.inspect(pointsPost)
                            postr = Ecto.Changeset.change(postr, %{:points => currentPoints - pointsPost})

                            case Rewardapp.Repo.update(postr) do
                              {:ok, _params} ->
                                conn
                                |> put_flash(:info, "Changed points")
                                |> Plug.Conn.delete_session(:userInfo)
                                |> redirect(to: Routes.grant_path(conn, :admin))
                              {:error, _params} ->
                                conn
                                |> put_flash(:error, "Coult not delete given points")
                                |> redirect(to: Routes.grant_path(conn, :admin))
                        end
                          {:error, _params} ->
                            conn
                            |> put_flash(:error, "Coult not delete given points")
                            |> redirect(to: Routes.grant_path(conn, :admin))
                        end
                      {:error, _params} ->
                        conn
                        |> put_flash(:error, "Coult not delete given points")
                        |> redirect(to: Routes.grant_path(conn, :admin))
                      end
                  {:error, _params} ->
                    conn
                    |> put_flash(:info, "There was some error during saving to database")
                    |> redirect(to: Routes.grant_path(conn, :admin))
                end
              {:error, _params} ->
                  conn
                  |> put_flash(:info, "There was some error during saving to database")
                  |> redirect(to: Routes.grant_path(conn, :admin))
            end

          {:error, _params} ->
              conn
              |> put_flash(:error, "Coult not delete given points")
              |> redirect(to: Routes.grant_path(conn, :admin))
          end
    end


  end


  @spec logout(Plug.Conn.t(), any) :: Plug.Conn.t()
  def logout(conn, params) do
    conn
    |> put_flash(:info, "Logged out")
    |> Plug.Conn.configure_session(drop: true)
    |> redirect(to: Routes.page_path(conn, :start))
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
