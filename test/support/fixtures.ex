defmodule ExCnab.Test.Support.Fixtures do
  @payment_several "./test/fixtures/input_examples/payment_several.json"
  @ted_payment "./test/fixtures/input_examples/ted_payment.json"
  @statement "./test/fixtures/input_examples/statement_for_cash_management.json"

  def payment_several(_context) do
    json =
      @payment_several
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    [payment_several: json]
  end

  def ted_payment(_context) do
    json =
      @ted_payment
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    [ted_payment: json]
  end

  def statement_json(_context) do
    json =
      @statement
      |> Path.expand()
      |> File.read!()
      |> Poison.decode!()

    [statement_json: json]
  end

  def json_path(_context, fixture_id \\ nil) do
    case fixture_id do
      :payment -> [json_path: @payment_several]
      _ -> [json_path: @payment_several]
    end
  end
end
