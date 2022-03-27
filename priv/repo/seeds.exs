# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     HcAlpha.Repo.insert!(%HcAlpha.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

HcAlpha.Repo.insert!(%HcAlpha.Pos.Balance{
  account: "ak_nQpnNuBPQwibGpSJmjAah6r3ktAB7pG9JHuaGWHgLKxaKqEvC",
  balance: 0
})

HcAlpha.Repo.insert!(%HcAlpha.Pos.Balance{
  account: "ak_2MGLPW2CHTDXJhqFJezqSwYSNwbZokSKkG7wSbGtVmeyjGfHtm",
  balance: 0
})
