defmodule ExWebhook.Web.WebhookControllerTest do
  use ExWebhook.ConnCase, async: true
  alias ExWebhook.Factory
  alias Jason

  setup do
    :ok
  end

  test "GET /organizations/:tenant/webhooks should return 200 and empty list", %{conn: conn} do
    tenant_id = UUID.uuid4()

    conn = get(conn, "/organizations/#{tenant_id}/webhooks")

    assert conn.status == 200
    response_body = json_response(conn, 200)

    assert is_list(response_body["webhooks"])
    assert Enum.empty?(response_body["webhooks"])
  end

  test "GET /organizations/:tenant/webhooks should return 200 and registered webhooks", %{
    conn: conn
  } do
    tenant_id = UUID.uuid4()

    create_webhook_request(conn, tenant_id, "https://example.com/hook1", false, [])
    create_webhook_request(conn, tenant_id, "https://example.com/hook2", true, [])
    create_webhook_request(conn, tenant_id, "https://example.com/hook3", false, ["event3"])

    create_webhook_request(conn, tenant_id, "https://example.com/hook4", true, [
      "event4",
      "event5"
    ])

    create_webhook_request(conn, UUID.uuid4(), "https://postman-echo.com/post", false, [])

    conn = get(conn, "/organizations/#{tenant_id}/webhooks")

    assert conn.status == 200
    response_body = json_response(conn, 200)

    assert is_list(response_body["webhooks"])
    assert length(response_body["webhooks"]) == 4

    assert_webhooks = [
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook1",
        "isBatch" => false,
        "types" => []
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook2",
        "isBatch" => true,
        "types" => []
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook3",
        "isBatch" => false,
        "types" => ["event3"]
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook4",
        "isBatch" => true,
        "types" => ["event4", "event5"]
      }
    ]

    sorted_expected_webhooks =
      Enum.sort_by(assert_webhooks, & &1["url"])
      |> Enum.map(fn webhook -> %{webhook | "types" => Enum.sort(webhook["types"])} end)

    sorted_response_webhooks =
      Enum.sort_by(response_body["webhooks"], & &1["url"])
      |> Enum.map(fn webhook ->
        Map.delete(webhook, "id")
        |> Map.delete("createdAt")
        |> Map.update!("types", &Enum.sort(&1))
      end)

    assert sorted_response_webhooks == sorted_expected_webhooks
  end

  defp create_webhook_request(conn, tenant_id, url, is_batch, types) do
    endpoint = "/organizations/#{tenant_id}/webhooks"
    body = generate_webhook_payload(url, is_batch, types)

    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post(endpoint, body)

    assert response.status == 201
    response_body = json_response(response, 201)

    assert response_body != nil
    assert Map.has_key?(response_body, "types")
    assert is_list(response_body["types"])
    assert Enum.sort(response_body["types"]) == Enum.sort(types)
  end

  defp generate_webhook_payload(url, is_batch, types) do
    Jason.encode!(%{
      "url" => url,
      "isBatch" => is_batch,
      "types" => types
    })
  end
end
