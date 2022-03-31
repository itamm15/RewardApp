defmodule Rewardapp.Repo.Migrations.CreateAwards do
  use Ecto.Migration

  def change do
    create table(:awards) do
      add :userg, :string
      add :usergID, :integer
      add :userr, :string
      add :userrID, :integer
      add :points, :integer
    end
  end
end
