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

    create_webhook_request(conn, tenant_id, "https://example.com/hook1", [], false)
    create_webhook_request(conn, tenant_id, "https://example.com/hook2", [], true)
    create_webhook_request(conn, tenant_id, "https://example.com/hook3", ["event3"], false)

    create_webhook_request(
      conn,
      tenant_id,
      "https://example.com/hook4",
      ["event4", "event5"],
      true
    )

    create_webhook_request(conn, UUID.uuid4(), "https://example.com/hook5", ["event6"])
    create_webhook_request(conn, UUID.uuid4(), "https://postman-echo.com/post", [], false)

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
        "events" => []
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook2",
        "isBatch" => true,
        "events" => []
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook3",
        "isBatch" => false,
        "events" => ["event3"]
      },
      %{
        "tenantId" => tenant_id,
        "url" => "https://example.com/hook4",
        "isBatch" => true,
        "events" => ["event4", "event5"]
      }
    ]

    sorted_expected_webhooks =
      Enum.sort_by(assert_webhooks, & &1["url"])
      |> Enum.map(fn webhook -> %{webhook | "events" => Enum.sort(webhook["events"])} end)

    sorted_response_webhooks =
      Enum.sort_by(response_body["webhooks"], & &1["url"])
      |> Enum.map(fn webhook ->
        Map.delete(webhook, "id")
        |> Map.delete("createdAt")
        |> Map.update!("events", &Enum.sort(&1))
      end)

    assert sorted_response_webhooks == sorted_expected_webhooks
  end

  defp create_webhook_request(conn, tenant_id, url, events, is_batch \\ nil) do
    endpoint = "/organizations/#{tenant_id}/webhooks"
    body = generate_webhook_payload(url, events, is_batch)

    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post(endpoint, body)

    assert response.status == 201
    response_body = json_response(response, 201)

    assert response_body != nil
    assert Map.has_key?(response_body, "events")
    assert is_list(response_body["events"])
    assert Enum.sort(response_body["events"]) == Enum.sort(events)

    case is_batch do
      nil ->
        assert response_body["isBatch"] == false

      _ ->
        assert response_body["isBatch"] == is_batch
    end
  end

  defp generate_webhook_payload(url, events, is_batch) do
    payload =
      %{
        "url" => url,
        "events" => events
      }
      |> maybe_put_is_batch(is_batch)

    Jason.encode!(payload)
  end

  defp maybe_put_is_batch(payload, nil), do: payload
  defp maybe_put_is_batch(payload, is_batch), do: Map.put(payload, "isBatch", is_batch)
end
