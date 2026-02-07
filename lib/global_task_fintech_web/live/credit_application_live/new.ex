defmodule GlobalTaskFintechWeb.CreditApplicationLive.New do
  use GlobalTaskFintechWeb, :live_view

  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Domain.Entities.CreditApplication

  def mount(%{"country" => country}, _session, socket) do
    country = String.upcase(country)
    changeset = Applications.change_credit_application(%CreditApplication{country: country})
    {:ok, assign(socket, form: to_form(changeset, as: :credit_application), country: country)}
  end

  def handle_event("validate", %{"credit_application" => params}, socket) do
    params = Map.put(params, "country", socket.assigns.country)

    changeset =
      %CreditApplication{}
      |> Applications.change_credit_application(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: :credit_application))}
  end

  def handle_event("save", %{"credit_application" => params}, socket) do
    params = Map.put(params, "country", socket.assigns.country)

    case Applications.create_credit_application(params) do
      {:ok, _application} ->
        {:noreply,
         socket
         |> put_flash(:info, "Application submitted successfully")
         |> push_navigate(to: ~p"/credit-applications/#{socket.assigns.country}/new")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :credit_application))}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl py-12 px-4 sm:px-6 lg:px-8">
      <div class="bg-base-100 shadow-2xl rounded-3xl overflow-hidden border border-base-200">
        <div class="px-6 py-8 sm:px-10 border-b border-base-200 bg-linear-to-b from-white to-base-200/50">
          <h3 class="text-2xl font-extrabold text-base-content tracking-tight">
            Credit Application
          </h3>
          <p class="mt-2 text-sm text-base-content/60">
            Please fill out the form below to apply for credit.
          </p>
        </div>

        <div class="px-6 py-8 sm:px-10">
          <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-8">
            <div class="grid grid-cols-1 gap-y-6 gap-x-6 sm:grid-cols-6">
              <div class="sm:col-span-6">
                <.input
                  field={@form[:full_name]}
                  type="text"
                  label="Full Name"
                  placeholder="e.g. Juan Perez"
                  required
                />
              </div>

              <div class="sm:col-span-3">
                <.input
                  field={@form[:document_type]}
                  type="select"
                  label="Document Type"
                  options={[
                    {"National ID (CC/INE)", "id_card"},
                    {"Passport", "passport"},
                    {"Driver's License", "license"}
                  ]}
                  prompt="Select document type"
                />
              </div>

              <div class="sm:col-span-3">
                <.input
                  field={@form[:document_value]}
                  type="text"
                  label="Document Number"
                  placeholder="e.g. 123456789"
                  required
                />
              </div>

              <div class="sm:col-span-3">
                <.input
                  field={@form[:monthly_income]}
                  type="number"
                  label="Monthly Income"
                  step="0.01"
                  min="0"
                  required
                />
              </div>

              <div class="sm:col-span-3">
                <.input
                  field={@form[:amount_requested]}
                  type="number"
                  label="Amount Requested"
                  step="0.01"
                  min="0"
                  required
                />
              </div>
            </div>

            <div class="pt-4 flex justify-end">
              <.button
                phx-disable-with="Submitting..."
                variant="primary"
                class="w-full sm:w-auto px-10 py-3 text-base font-semibold shadow-lg shadow-primary/20 transition-all hover:scale-[1.02] active:scale-[0.98]"
              >
                Submit Application
              </.button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end
end
