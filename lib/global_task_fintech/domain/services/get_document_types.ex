defmodule GlobalTaskFintech.Domain.Services.GetDocumentTypes do
  @moduledoc """
  Service for retrieving supported document types by country.
  """

  @doc """
  Returns the available document types for a given country.
  """
  def execute("MX") do
    [
      {"CURP", "curp"}
    ]
  end

  def execute("CO") do
    [
      {"Cédula de Ciudadanía (CC)", "cc"}
    ]
  end

  def execute(_), do: []
end
