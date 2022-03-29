defmodule RewardappWeb.PageController do
  use RewardappWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
