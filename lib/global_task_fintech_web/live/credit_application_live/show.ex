defmodule GlobalTaskFintechWeb.CreditApplicationLive.Show do
  use GlobalTaskFintechWeb, :live_view

  alias GlobalTaskFintech.Applications

  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket),
      do: Phoenix.PubSub.subscribe(GlobalTaskFintech.PubSub, "credit_applications:#{id}")

    application = Applications.get_credit_application!(id)
    {:ok, assign(socket, application: application, page_title: "Application Details")}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info({:application_updated, application}, socket) do
    {:noreply, assign(socket, :application, application)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-5xl py-8 px-4 sm:px-6 lg:px-8">
      <div class="mb-8">
        <.link
          navigate={~p"/credit-applications"}
          class="text-sm font-semibold leading-6 text-indigo-600 hover:text-indigo-500 flex items-center gap-1"
        >
          <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to applications
        </.link>
      </div>

      <div class="overflow-hidden bg-white shadow sm:rounded-lg dark:bg-zinc-900 border dark:border-zinc-800">
        <div class="px-4 py-6 sm:px-6 flex justify-between items-center bg-gray-50 dark:bg-zinc-800/50">
          <div>
            <h3 class="text-base font-semibold leading-7 text-gray-900 dark:text-gray-100">
              Application Information
            </h3>
            <p class="mt-1 max-w-2xl text-sm leading-6 text-gray-500 dark:text-gray-400">
              Details and context for this credit request.
            </p>
          </div>
          <span class={[
            "inline-flex items-center rounded-md px-3 py-1 text-sm font-medium ring-1 ring-inset",
            @application.status == :approved &&
              "bg-green-50 text-green-700 ring-green-600/20 dark:bg-green-900/30 dark:text-green-400",
            @application.status == :rejected &&
              "bg-red-50 text-red-700 ring-red-600/10 dark:bg-red-900/30 dark:text-red-400",
            @application.status == :pending &&
              "bg-yellow-50 text-yellow-800 ring-yellow-600/20 dark:bg-yellow-900/30 dark:text-yellow-400",
            @application.status == :manual_review &&
              "bg-blue-50 text-blue-700 ring-blue-600/20 dark:bg-blue-900/30 dark:text-blue-400",
            @application.status == :risk_check &&
              "bg-purple-50 text-purple-700 ring-purple-600/20 dark:bg-purple-900/30 dark:text-purple-400"
          ]}>
            {String.capitalize(to_string(@application.status))}
          </span>
        </div>
        <div class="border-t border-gray-100 dark:border-zinc-800 px-4 py-6 sm:px-6">
          <dl class="grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2">
            <div class="sm:col-span-1">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Full Name</dt>
              <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">{@application.full_name}</dd>
            </div>
            <div class="sm:col-span-1">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Country</dt>
              <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                <span class="flex items-center gap-2">
                  <span class="uppercase font-bold">{@application.country}</span>
                  <span class="text-gray-400">|</span>
                  {if @application.country == "MX", do: "Mexico", else: "Colombia"}
                </span>
              </dd>
            </div>
            <div class="sm:col-span-1">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Document Type</dt>
              <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                {@application.document_type}
              </dd>
            </div>
            <div class="sm:col-span-1">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Document Number</dt>
              <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
                {@application.document_number}
              </dd>
            </div>
            <div class="sm:col-span-1 border-t dark:border-zinc-800 pt-4">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Monthly Income</dt>
              <dd class="mt-1 text-lg font-semibold text-gray-900 dark:text-gray-100">
                ${@application.monthly_income}
              </dd>
            </div>
            <div class="sm:col-span-1 border-t dark:border-zinc-800 pt-4">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Amount Requested</dt>
              <dd class="mt-1 text-lg font-semibold text-gray-900 dark:text-gray-100 text-indigo-600 dark:text-indigo-400">
                ${@application.amount_requested}
              </dd>
            </div>

            <div class="sm:col-span-2 border-t dark:border-zinc-800 pt-4">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">
                Risk Assessment / Notes
              </dt>
              <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100 bg-gray-50 dark:bg-zinc-800 p-4 rounded-md italic">
                {if @application.risk_reason,
                  do: @application.risk_reason,
                  else: "No additional notes provided by the risk engine."}
              </dd>
            </div>

            <div :if={@application.bank_data} class="sm:col-span-2 border-t dark:border-zinc-800 pt-4">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400 mb-2">
                Verified Bank Data
              </dt>
              <dd class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div class="bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded border dark:border-zinc-700">
                  <span class="block text-xs text-gray-500 uppercase font-bold mb-1">Bank Name</span>
                  <span class="text-sm font-medium text-gray-900 dark:text-gray-100">
                    {@application.bank_data["bank_name"]}
                  </span>
                </div>
                <div class="bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded border dark:border-zinc-700">
                  <span class="block text-xs text-gray-500 uppercase font-bold mb-1">
                    Credit Score
                  </span>
                  <span class="text-sm font-medium text-gray-900 dark:text-gray-100">
                    {@application.bank_data["credit_score"]}
                  </span>
                </div>
                <div class="bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded border dark:border-zinc-700">
                  <span class="block text-xs text-gray-500 uppercase font-bold mb-1">
                    Validation Date
                  </span>
                  <span class="text-sm font-medium text-gray-900 dark:text-gray-100">
                    {Calendar.strftime(@application.inserted_at, "%Y-%m-%d %H:%M")}
                  </span>
                </div>
              </dd>
            </div>

            <div class="sm:col-span-2 border-t dark:border-zinc-800 pt-4">
              <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">Timestamp</dt>
              <dd class="mt-1 text-sm text-gray-500 dark:text-gray-400">
                Submitted on {Calendar.strftime(@application.inserted_at, "%B %d, %Y at %H:%M")} UTC
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </div>
    """
  end
end
