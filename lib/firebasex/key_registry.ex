defmodule Firebasex.KeyRegistry do
  use Agent
  use Injector
  alias __MODULE__, as: This

  inject(Firebasex.GoogleKeys)

  def start_link(_) do
    map = GoogleKeys.fetch()
    Agent.start_link(fn -> map end, name: This)
  end

  def value(id) do
    case check_for_value(id) do
      {:error, "google_signature_not_found"} ->
        # check if the values need to be refreshed
        replace_map()
        # check again with refreshed values
        check_for_value(id)

      {:ok, value} ->
        {:ok, value}
    end
  end

  defp check_for_value(id) do
    case Agent.get(This, &Map.get(&1, id, nil)) do
      nil -> {:error, "google_signature_not_found"}
      value -> {:ok, value}
    end
  end

  defp replace_map do
    map = GoogleKeys.fetch()
    Agent.update(This, fn _ -> map end)
  end
end
