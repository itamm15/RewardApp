defmodule RewardappWeb.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :april, :integer
    field :august, :integer
    field :december, :integer
    field :february, :integer
    field :january, :integer
    field :july, :integer
    field :june, :integer
    field :march, :integer
    field :may, :integer
    field :name, :string
    field :november, :integer
    field :october, :integer
    field :points, :integer
    field :role, :string
    field :september, :integer
    field :surname, :string
    field :mail, :string
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name, :surname, :role, :points, :mail, :january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december])
    |> validate_required([:name, :surname, :role, :points, :mail, :january, :february, :march, :april, :may, :june, :july, :august, :september, :october, :november, :december])
  end
end
