defmodule Rewardapp.Award do
  use Ecto.Schema
  import Ecto.Changeset

  schema "awards" do
    field :points, :integer
    field :usergID, :integer
    field :userg, :string
    field :userrID, :integer
    field :userr, :string
  end

  @doc false
  def changeset(award, attrs) do
    award
    |> cast(attrs, [:userg, :userr, :points, :usergID, :userrID])
    |> validate_required([:userg, :userr, :points, :usergID, :userrID])
  end
end
