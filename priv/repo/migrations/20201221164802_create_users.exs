defmodule Blog.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :display_name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :image, :string

      timestamps
    end

    create unique_index(:users, [:email])
  end
end
