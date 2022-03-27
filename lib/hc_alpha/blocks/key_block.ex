defmodule HcAlpha.Blocks.KeyBlock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:hash, :string, autogenerate: false}
  schema "key_blocks" do
    field :prev_hash, :string, null: false
    field :height, :integer
    field :beneficiary, :string
    field :validator, :string

    # field :timestamp, :utc_datetime

    timestamps()
  end

  @fields [:hash, :prev_hash, :height, :beneficiary, :validator]

  @doc false
  def changeset(block, attrs) do
    block
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
