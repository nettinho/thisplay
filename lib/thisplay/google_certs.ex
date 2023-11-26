defmodule GoogleCerts do
  @pem_certs "https://www.googleapis.com/oauth2/v1/certs"
  @jwk_certs "https://www.googleapis.com/oauth2/v3/certs"
  @iss "https://accounts.google.com"

  def verified_identity(%{jwt: jwt}) do
    with {:ok, profile} <- check_identity_v1(jwt),
         {:ok, true} <- run_checks(profile) do
      {:ok, profile}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  # PEM version
  def check_identity_v1(jwt) do
    with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, body} <- fetch(@pem_certs) do
      {true, %{fields: fields}, _} =
        body
        |> Map.get(kid)
        |> JOSE.JWK.from_pem()
        |> JOSE.JWT.verify_strict([alg], jwt)

      {:ok, fields}
    else
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  # JWK version
  def check_identity_v3(jwt) do
    with {:ok, %{"kid" => kid, "alg" => alg}} <- Joken.peek_header(jwt),
         {:ok, body} <- fetch(@jwk_certs) do
      %{"keys" => certs} = body
      cert = Enum.find(certs, fn cert -> cert["kid"] == kid end)
      signer = Joken.Signer.create(alg, cert)
      Joken.verify(jwt, signer, [])
    else
      {:error, reason} -> {:error, inspect(reason)}
    end
  end

  defp fetch(url) do
    case Req.get(url) do
      {:ok, %{body: body}} ->
        {:ok, body}

      error ->
        {:error, error}
    end
  end

  # ---- Google recommendations

  def run_checks(claims) do
    %{
      "exp" => exp,
      "aud" => aud,
      "azp" => azp,
      "iss" => iss
    } = claims

    with {:ok, true} <- not_expired(exp),
         {:ok, true} <- check_iss(iss),
         {:ok, true} <- check_user(aud, azp) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
    end
  end

  def not_expired(exp) do
    case exp > DateTime.to_unix(DateTime.utc_now()) do
      true -> {:ok, true}
      false -> {:error, :expired}
    end
  end

  def check_user(aud, azp) do
    case aud == app_id() || azp == app_id() do
      true -> {:ok, true}
      false -> {:error, :wrong_id}
    end
  end

  def check_iss(iss) do
    case iss == @iss do
      true -> {:ok, true}
      false -> {:ok, :wrong_issuer}
    end
  end

  defp app_id, do: System.get_env("GOOGLE_CLIENT_ID")
end
