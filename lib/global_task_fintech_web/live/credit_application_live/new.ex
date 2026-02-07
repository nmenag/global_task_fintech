defmodule GlobalTaskFintechWeb.CreditApplicationLive.New do
  use GlobalTaskFintechWeb, :live_view

  alias GlobalTaskFintech.Applications

  def mount(%{"country" => country}, _session, socket) do
    country = String.upcase(country)

    changeset =
      Applications.change_credit_application(
        Applications.new_credit_application(%{country: country})
      )

    {:ok, assign(socket, form: to_form(changeset, as: :credit_application), country: country)}
  end

  def handle_event("validate", %{"credit_application" => params}, socket) do
    params = Map.put(params, "country", socket.assigns.country)

    changeset =
      Applications.new_credit_application()
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
    <div class="mx-auto max-w-2xl py-8 px-4 sm:px-6 lg:px-8">
      <div class="bg-white dark:bg-zinc-900 shadow sm:rounded-lg overflow-hidden">
        <div class="px-4 py-5 sm:px-6 border-b border-gray-200 dark:border-zinc-800">
          <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">
            Credit Application
          </h3>
          <p class="mt-1 max-w-2xl text-sm text-gray-500 dark:text-gray-400">
            Please fill out the form below to apply for credit.
          </p>
        </div>

        <div class="px-4 py-5 sm:p-6">
          <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6">
            <div
              :if={@country}
              class="bg-gray-50 dark:bg-zinc-800 p-4 rounded-md border border-gray-200 dark:border-zinc-700"
            >
              <span class="text-sm font-medium text-gray-500 dark:text-gray-400">Applying from:</span>
              <span class="ml-2 text-sm font-bold text-gray-900 dark:text-gray-100">{@country}</span>
            </div>

            <div class="grid grid-cols-1 gap-y-6 gap-x-4 sm:grid-cols-6">
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
                  options={Applications.get_document_types(@country)}
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

            <div class="pt-5 flex justify-end">
              <.button
                phx-disable-with="Submitting..."
                class="ml-3 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
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
