defmodule GoogleVisionAPI do
  @api_key Application.compile_env(:thisplay, GoogleVisionAPI, :api_key)
  @google_vision_api_url "https://vision.googleapis.com/v1/images:annotate?key=#{@api_key}"

  def detect_objects(image_path) do
    # Leer y codificar la imagen en base64
    image_content = File.read!(image_path) |> Base.encode64()

    # Crear el cuerpo de la solicitud
    body = %{
      requests: [
        %{
          image: %{content: image_content},
          features: [%{type: "OBJECT_LOCALIZATION", maxResults: 10}]
        }
      ]
    }

    # Hacer la solicitud POST a la API de Google Cloud Vision
    response =
      HTTPoison.post!(@google_vision_api_url, Jason.encode!(body), [
        {"Content-Type", "application/json"}
      ])

    # Manejar la respuesta
    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        Jason.decode!(body)

      %HTTPoison.Response{status_code: status_code, body: body} ->
        IO.puts("Error: #{status_code}")
        IO.inspect(body)
    end
  end
end
