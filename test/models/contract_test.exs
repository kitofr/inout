defmodule Inout.ContractTest do
  use Inout.ModelCase

  alias Inout.Contract

  @valid_attrs %{address: "some content", client: "some content", country: "some content", description: "some content", email: "some content", hourly_rate: 42, postalcode: "some content", reference: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Contract.changeset(%Contract{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Contract.changeset(%Contract{}, @invalid_attrs)
    refute changeset.valid?
  end
end
