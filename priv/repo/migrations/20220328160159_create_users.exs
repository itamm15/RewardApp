defmodule Rewardapp.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :surname, :string
      add :role, :string
      add :points, :integer, default: 0
      add :mail, :string
      add :january, :integer, default: 50
      add :february, :integer, default: 50
      add :march, :integer, default: 50
      add :april, :integer, default: 50
      add :may, :integer, default: 50
      add :june, :integer, default: 50
      add :july, :integer, default: 50
      add :august, :integer, default: 50
      add :september, :integer, default: 50
      add :october, :integer, default: 50
      add :november, :integer, default: 50
      add :december, :integer, default: 50
    end
  end
end
