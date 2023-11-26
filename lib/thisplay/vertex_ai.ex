defmodule VertexAI do
  def image_embedding(image_path) do
    # location = Application.get_env(:thisplay, VertexAI)[:location]
    location = "us-central1"
    project_id = Application.get_env(:thisplay, VertexAI)[:project_id]
    _index_id = Application.get_env(:thisplay, VertexAI)[:index_id]
    _token = Application.get_env(:thisplay, VertexAI)[:token]

    # api_key = Application.get_env(:thisplay, GoogleVisionAPI)[:api_key]
    %Goth.Token{token: api_key} = Goth.fetch!(Thisplay.Goth)

    url =
      "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/publishers/google/models/multimodalembedding@001:predict"

    # {:ok, image} = File.read(image_path)

    # b64 = Base.encode64(image)

    # body = %{instances: [%{image: %{bytesBase64Encoded: b64}}]}

    body = %{instances: [%{image: %{gcsUri: "gs://thisplay/#{image_path}"}}]}

    url
    |> HTTPoison.post!(
      Jason.encode!(body),
      [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ],
      timeout: 60000
    )
    |> case do
      %{status_code: 200, body: body} -> body
      _ -> "{}"
    end
    |> Jason.decode!()
    |> case do
      %{
        "predictions" => [
          %{
            "imageEmbedding" => embedding
          }
        ]
      } ->
        embedding

      _ ->
        nil
    end
  end

  def google_storage_post(filename) do
    # filename = "/Users/netto/Downloads/IMG_2583.jpg"

    filehash =
      filename
      |> File.read!()
      |> then(&:crypto.hash(:md5, &1))
      |> Base.encode32()

    bucket = "thisplay"
    %Goth.Token{token: api_key} = Goth.fetch!(Thisplay.Goth)

    url =
      "https://storage.googleapis.com/upload/storage/v1/b/#{bucket}/o?uploadType=media&name=#{filehash}"

    url
    |> HTTPoison.post!(
      {:file, filename},
      [{"Authorization", "Bearer #{api_key}"}]
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> Map.get("name")
  end

  def google_storage_get(filename) do
    localpath = "/tmp/#{filename}"

    bucket = "thisplay"
    %Goth.Token{token: api_key} = Goth.fetch!(Thisplay.Goth)

    url = "https://storage.googleapis.com/storage/v1/b/#{bucket}/o/#{filename}?alt=media"

    url
    |> HTTPoison.get!([{"Authorization", "Bearer #{api_key}"}])
    |> Map.get(:body)
    |> then(&File.write!(localpath, &1))

    localpath
  end

  def google_storage_signed_url(filename) do
    bucket = "thisplay"
    # filename = "lCRV0NoPO4o6ltko8awGQg=="

    System.get_env("G_CREDS")
    |> Base.decode64!()
    |> Jason.decode!()
    |> GcsSignedUrl.Client.load()
    |> GcsSignedUrl.generate_v4(bucket, filename)
  end

  # def embedding_upsert(embedding) do
  #   location = "europe-west1"
  #   # Application.get_env(:thisplay, VertexAI)[:index_id]
  #   index_id = "5268701390628192256"
  #   project_id = Application.get_env(:thisplay, VertexAI)[:project_id]
  #   api_key = ""

  #   url =
  #     "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/indexes/#{index_id}:upsertDatapoints"

  #   body = %{
  #     datapoints: [
  #       %{datapointId: "2", featureVector: embedding}
  #     ]
  #   }

  #   url
  #   |> HTTPoison.post!(Jason.encode!(body), [
  #     {"Content-Type", "application/json"},
  #     {"Authorization", "Bearer #{api_key}"}
  #   ])
  # end

  # def create_index do
  #   location = "europe-west1"
  #   project_id = Application.get_env(:thisplay, VertexAI)[:project_id]

  #   _url =
  #     "https://#{location}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{location}/indexes/"

  #   _body = %{
  #     displayName: "test_api_1",
  #     description: "test_api_1",
  #     metadata: %{
  #       contentsDeltaUri: "gs://thisplay/test",
  #       config: %{
  #         dimensions: "1408",
  #         approximateNeighborsCount: 1,
  #         distanceMeasureType: "DOT_PRODUCT_DISTANCE",
  #         algorithmConfig: %{
  #           treeAhConfig: %{leafNodeEmbeddingCount: 10000, leafNodesToSearchPercent: 2}
  #         }
  #       }
  #     },
  #     indexUpdateMethod: "STREAM_UPDATE"
  #   }
  # end

  # cloud storage https://console.cloud.google.com/storage/browser/thisplay/batch_root?hl=es-419&project=novahack2023&pageState=(%22StorageObjectListTable%22:(%22f%22:%22%255B%255D%22))&prefix=&forceOnObjectsSortingFiltering=false
  # vectors https://console.cloud.google.com/vertex-ai/matching-engine/indexes?hl=es-419&_ga=2.121499400.1666736625.1700428260-1608122005.1700428260&project=novahack2023
  # handle vectors https://cloud.google.com/vertex-ai/docs/vector-search/update-rebuild-index?hl=es-419#update_index-drest

  # """
  # upsert data points
  # POST
  # https://europe-west1-a-aiplatform.googleapis.com/v1/projects/novahack2023/locations/europe-west1-a/indexes/5462356174605123584:upsertDatapoints

  # {datapoint_id: "1", feature_vector: <vector array>}
  # """
end
