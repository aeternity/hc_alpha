defmodule HcAlpha.Repo.Migrations.AddHeightBalanceToValidators do
  use Ecto.Migration

  @table :validators
  def up do
    alter table(@table) do
      add :height, :decimal
      add :balance, :decimal
    end

    drop unique_index(@table, [:address])
    create unique_index(@table, [:address, :height])
  end

  def down do
    alter table(@table) do
      remove :height
      remove :balance
    end

    drop unique_index(@table, [:address, :height])
    create unique_index(@table, [:address])
  end
end
