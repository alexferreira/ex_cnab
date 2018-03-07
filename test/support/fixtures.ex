defmodule ExCnab.Test.Support.Fixtures do
  @payment "/opt/app/test/fixtures/payment_input.json"

  def payment_json(_context) do
    json =
      @payment
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    [payment_json: json]
  end

  def json_path(_context, fixture_id \\ nil) do
    case fixture_id do
      :payment -> [json_path: @payment]
      _ -> [json_path: @payment]
    end
  end
end
