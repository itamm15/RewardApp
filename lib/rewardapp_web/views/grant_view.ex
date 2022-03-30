defmodule RewardappWeb.GrantView do
  use RewardappWeb, :view

  def currentUser(conn) do
    Plug.Conn.get_session(conn, :userInfo)
  end

end
