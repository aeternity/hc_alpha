defmodule HcAlpha.Node.Api do
  @moduledoc """
  API for talking directly to an aeternity node
  """

  def get(uri),
    do:
      uri
      |> url()
      |> HTTPoison.get()
      |> parse_response()

  def post(uri, body, headers \\ [{"Content-type", "application/json"}]),
    do:
      uri
      |> url()
      |> HTTPoison.post(Poison.encode!(body), headers)
      |> parse_response()

  def url(uri),
    do:
      :hc_alpha
      |> Application.fetch_env!(:node_url)
      |> URI.merge(uri)
      |> to_string()

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: {:ok, parse_body(body)}

  defp parse_response({:ok, %HTTPoison.Response{status_code: status_code, body: reason}}),
    do: {:error_code, status_code, reason}

  defp parse_response({:error, %HTTPoison.Error{reason: reason}}), do: {:error, reason}

  defp parse_body(body), do: Poison.decode!(body)
end
