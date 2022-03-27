defmodule HcAlpha.Repo.Migrations.AddPosTables do
  use Ecto.Migration

  def up do
    create table(:pos_balances) do
      add :account, :string, null: false, primary_key: true
      add :balance, :decimal

      timestamps()
    end

    create unique_index(:pos_balances, [:account])
    # create table(:pos_leaders) do
    #  add :account, :string, null: false
    # end
  end

  def down do
    drop table(:pos_balances)
  end
end
