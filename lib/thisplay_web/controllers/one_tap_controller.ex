defmodule ThisplayWeb.OneTapController do
  use ThisplayWeb, :controller

  alias Thisplay.Accounts
  alias ThisplayWeb.UserAuth

  def login(conn, %{"credential" => jwt}) do
    {:ok,
     %{
       "email" => email,
       "name" => name,
       "picture" => picture
     }} = GoogleCerts.verified_identity(%{jwt: jwt})

    email
    |> String.split("@")
    |> check_email_domain
    |> fetch_user(email)
    |> maybe_create_user(%{email: email, name: name, picture: picture})
    |> maybe_login(conn)

    {:ok, user} =
      case Accounts.get_user_by_email(email) do
        nil -> Accounts.create_user(%{email: email, name: name, picture: picture})
        user -> {:ok, user}
      end

    UserAuth.log_in_user(conn, user)
  end

  defp check_email_domain([_, "bluetab.net"]), do: :ok
  defp check_email_domain([_, "google.com"]), do: :ok
  defp check_email_domain([_, _]), do: :invalid_email

  defp fetch_user(:ok, email), do: Accounts.get_user_by_email(email)
  defp fetch_user(error, _), do: error

  defp maybe_create_user(nil, params), do: Accounts.create_user(params)
  defp maybe_create_user(%{} = user, _), do: {:ok, user}
  defp maybe_create_user(error, _), do: error

  defp maybe_login({:ok, user}, conn), do: UserAuth.log_in_user(conn, user)

  defp maybe_login(:invalid_email, conn),
    do: handle_error(conn, "Only 'bluetab.net' and 'google.com' emails are accepted.")

  defp maybe_login(_, conn),
    do: handle_error(conn, "Error creating session.")

  defp handle_error(conn, message),
    do:
      conn
      |> put_flash(:error, message)
      |> delete_resp_cookie("g_csrf_token")
      |> redirect(to: ~p"/landing")
end
