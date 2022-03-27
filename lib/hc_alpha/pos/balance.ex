defmodule HcAlpha.Pos.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:account, :string, autogenerate: false}
  schema "pos_balances" do
    field :balance, :decimal

    timestamps()
  end

  @fields [:account, :balance]

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
