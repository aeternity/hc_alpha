defmodule HcAlpha.Repo.Migrations.AddKeyblockTable do
  use Ecto.Migration

  # TODO add unique to hash

  def up do
    create table(:key_blocks) do
      add :hash, :string, null: false, primary_key: true
      add :prev_hash, :string, null: false

      add :height, :integer
      # add :timestamp, :utc_datetime

      add :beneficiary, :string
      add :validator, :string

      timestamps()
    end
  end

  def down do
    drop table(:key_blocks)
  end
end
