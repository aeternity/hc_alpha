defmodule HcAlpha.Repo.Migrations.AddValidatorsTable do
  use Ecto.Migration

  def up do
    create table(:validators) do
      add :address, :string, null: false, primary_key: true
      add :status, :string
      add :stake, :decimal

      timestamps()
    end

    create unique_index(:validators, [:address])
  end

  def down do
    drop table(:validators)
  end
end
