defmodule HcAlpha.Pos.Validator do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:address, :string, autogenerate: false}
  schema "validators" do
    field :height, :decimal
    field :status, Ecto.Enum, values: [:online, :offline]
    field :stake, :decimal
    field :balance, :decimal

    timestamps()
  end

  @unique [:address, :height]
  @fields_required @unique ++ [:status, :stake]
  @fields [:balance | @fields_required]

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, @fields)
    |> validate_required(@fields_required)
    |> unique_constraint(@unique)
  end
end
