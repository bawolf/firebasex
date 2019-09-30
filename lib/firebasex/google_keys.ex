defmodule Firebasex.GoogleKeys do
  @url "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  def fetch do
    with %HTTPoison.Response{status_code: 200, body: body} <- HTTPoison.get!(@url),
         {:ok, map} <- Jason.decode(body) do
      map
    else
      _ -> Map.new()
    end
  end
end
