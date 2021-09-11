defmodule Tanoki.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :unit_price, :float
      add :sku, :integer

      timestamps()
    end

    create constraint(:products, :unit_price_must_be_positive, check: "unit_price > 0")
    create unique_index(:products, [:sku])
  end
end
