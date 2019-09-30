defmodule Firebasex do
  use Injector

  @project_id Application.get_env(:firebasex, :project_id)
  @issuer "https://securetoken.google.com/"

  inject(Firebasex.KeyRegistry)

  def verify(token) when is_binary(token) do
    with {:ok, kid} <- kid_for_signature(token),
         {:ok, pem} <- pem_for(kid),
         {:ok, fields} <- verify_google_signature(pem, token),
         :ok <- verify_token_is_from_app(fields),
         :ok <- verify_not_expired(fields) do
      {:ok, fields}
    end
  end

  def kid_for_signature(token) do
    try do
      %{"kid" => kid} = JOSE.JWT.peek_protected(token).fields
      {:ok, kid}
    rescue
      Jason.DecodeError -> {:error, "invalid_token"}
    end
  end

  defp pem_for(kid) do
    KeyRegistry.value(kid)
  end

  def verify_google_signature(pem, token) do
    jwk = JOSE.JWK.from_pem(pem)

    case JOSE.JWT.verify_strict(jwk, ["RS256"], token) do
      {true, %JOSE.JWT{fields: fields}, _} -> {:ok, fields}
      {false, _, _} -> {:error, "token_not_signed_by_google"}
    end
  end

  defp verify_token_is_from_app(fields) do
    if fields["iss"] == "#{@issuer}#{@project_id}" && fields["aud"] == @project_id do
      :ok
    else
      {:error, "signed_by_another_app"}
    end
  end

  defp verify_not_expired(fields) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    if fields["exp"] > now && fields["iat"] < now do
      :ok
    else
      {:error, "token_expired"}
    end
  end
end
