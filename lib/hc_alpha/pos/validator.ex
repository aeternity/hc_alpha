defmodule HcAlpha.Pos.Validator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:address, :string, autogenerate: false}
  schema "validators" do
    field :status, Ecto.Enum, values: [:online, :offline]
    field :stake, :decimal

    timestamps()
  end

  @fields [:address, :status, :stake]

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
