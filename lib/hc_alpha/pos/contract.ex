defmodule HcAlpha.Pos.Contract do
  def id(), do: get_env(:contract_id)

  def calldata(atom) when is_atom(atom), do: atom |> Atom.to_string() |> calldata()
  def calldata(fun) when is_binary(fun), do: fun |> calldata([])

  def calldata(fun, args) do
    c = code()
    f = to_args(fun)
    a = to_args(args)
    opts = [backend: :fate]
    {:ok, b} = :aeso_compiler.create_calldata(c, f, a, opts)
    :aeser_api_encoder.encode(:contract_bytearray, b)
  end

  def return_value(value) do
    :contract_bytearray
    |> :aeser_api_encoder.safe_decode(value)
    |> elem(1)
    |> :aeb_fate_encoding.deserialize()
    |> parse_value()
  end

  defp parse_value(list) when is_list(list), do: Enum.map(list, &parse_value/1)
  defp parse_value({:address, value}), do: :aeser_api_encoder.encode(:account_pubkey, value)

  defp parse_value({:tuple, tuple}) do
    tuple
    |> Tuple.to_list()
    |> Enum.map(&parse_value/1)
    |> List.to_tuple()
  end

  defp parse_value(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {parse_value(k), parse_value(v)} end)
    |> Enum.into(%{})
  end

  defp parse_value(other), do: other

  defp code() do
    case get_env(:contract_code) do
      nil -> get_code()
      code -> code
    end
  end

  defp get_code() do
    code =
      :hc_alpha
      |> :code.priv_dir()
      |> Path.join("contracts")
      |> Path.join(get_env(:contract_name))
      |> File.read!()
      |> to_args()

    :ok = Application.put_env(:hc_alpha, :contract_code, code)
    code
  end

  defp get_env(key) do
    :hc_alpha
    |> Application.get_env(key)
  end

  def to_args(bin) when is_binary(bin), do: :erlang.binary_to_list(bin)
  def to_args(int) when is_integer(int), do: to_args(Integer.to_string(int))
  def to_args(args), do: Enum.map(args, &to_args/1)
end
