defmodule Inout.EventTest do
  use Inout.ModelCase

  alias Inout.Event

  @valid_attrs %{
    device: "some content", 
    location: "some content", 
    status: "some content",
    user_id: 1,
    contract_id: 1
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Event.changeset(%Event{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Event.changeset(%Event{}, @invalid_attrs)
    refute changeset.valid?
  end
end
