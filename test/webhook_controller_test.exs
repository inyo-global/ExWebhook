defmodule ExWebhook.Web.WebhookControllerTest do
  use ExWebhook.ConnCase, async: true
  alias ExWebhook.Factory

  test "GET /organizations/:tenant/webhooks should return 200 and empty list", %{conn: conn} do
    tenant_id = UUID.uuid4()

    conn = get(conn, "/organizations/#{tenant_id}/webhooks")

    assert conn.status == 200
    response_body = json_response(conn, 200)

    assert is_list(response_body["webhooks"])
    assert Enum.empty?(response_body["webhooks"])
  end

  test "GET /organizations/:tenant/webhooks should return 200 and registered webhooks", %{conn: conn} do
    tenant_id = UUID.uuid4()
    Factory.insert!(:webhook, tenant_id: tenant_id, url: "http://example.com/hook1", is_batch: false)
    Factory.insert!(:webhook, tenant_id: tenant_id, url: "http://example.com/hook2", is_batch: true)
    Factory.insert!(:webhook)

    conn = get(conn, "/organizations/#{tenant_id}/webhooks")

    assert conn.status == 200
    response_body = json_response(conn, 200)

    assert is_list(response_body["webhooks"])
    assert length(response_body["webhooks"]) == 2
    assert Enum.all?(response_body["webhooks"], fn webhook ->
      Map.has_key?(webhook, "tenantId") && webhook["tenantId"] == tenant_id
    end)
    returned_urls = Enum.map(response_body["webhooks"], & &1["url"])
    assert Enum.sort(returned_urls) == Enum.sort(["http://example.com/hook1", "http://example.com/hook2"])
  end
end
