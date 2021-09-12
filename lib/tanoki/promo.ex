defmodule Tanoki.Promo do
  alias Tanoki.Promo.Recipient

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_promo(_recipient, _attrs) do
    :noop
  end
end
