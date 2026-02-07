defmodule GlobalTaskFintechWeb.CreditApplicationLive.Index do
  use GlobalTaskFintechWeb, :live_view

  alias GlobalTaskFintech.Applications

  def mount(_params, _session, socket) do
    {:ok, assign(socket, applications: [], filters: %{"country" => "", "status" => ""})}
  end

  def handle_params(params, _uri, socket) do
    filters = %{
      "country" => params["country"] || "",
      "status" => params["status"] || ""
    }

    applications = Applications.list_credit_applications(filters)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:applications, applications)}
  end

  def handle_event("filter", %{"country" => country, "status" => status}, socket) do
    params = %{country: country, status: status}
    {:noreply, push_patch(socket, to: ~p"/credit-applications?#{params}")}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl py-8 px-4 sm:px-6 lg:px-8">
      <div class="sm:flex sm:items-center">
        <div class="sm:flex-auto">
          <h1 class="text-2xl font-semibold leading-6 text-gray-900 dark:text-gray-100">
            Credit Applications
          </h1>
          <p class="mt-2 text-sm text-gray-700 dark:text-gray-400">
            A list of all the credit applications received.
          </p>
        </div>
        <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
          <.link
            navigate={~p"/credit-applications/mx/new"}
            class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
          >
            New Application
          </.link>
        </div>
      </div>

      <div class="mt-8 flex flex-col sm:flex-row gap-4">
        <form phx-change="filter" class="flex flex-col sm:flex-row gap-4 w-full">
          <div class="w-full sm:w-1/4">
            <label for="country" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              Country
            </label>
            <select
              id="country"
              name="country"
              class="mt-1 block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700 dark:text-gray-200"
            >
              <option value="">All Countries</option>
              <option value="MX" selected={@filters["country"] == "MX"}>Mexico</option>
              <option value="CO" selected={@filters["country"] == "CO"}>Colombia</option>
            </select>
          </div>

          <div class="w-full sm:w-1/4">
            <label for="status" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              Status
            </label>
            <select
              id="status"
              name="status"
              class="mt-1 block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-indigo-500 focus:outline-none focus:ring-indigo-500 sm:text-sm dark:bg-zinc-800 dark:border-zinc-700 dark:text-gray-200"
            >
              <option value="">All Statuses</option>
              <option value="pending" selected={@filters["status"] == "pending"}>Pending</option>
              <option value="approved" selected={@filters["status"] == "approved"}>Approved</option>
              <option value="rejected" selected={@filters["status"] == "rejected"}>Rejected</option>
            </select>
          </div>
        </form>
      </div>

      <div class="mt-8 flow-root">
        <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
            <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
              <table class="min-w-full divide-y divide-gray-300 dark:divide-zinc-800">
                <thead class="bg-gray-50 dark:bg-zinc-800">
                  <tr>
                    <th
                      scope="col"
                      class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 dark:text-gray-100 sm:pl-6"
                    >
                      Full Name
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-100"
                    >
                      Country
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-100"
                    >
                      Income
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-100"
                    >
                      Requested
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-100"
                    >
                      Status
                    </th>
                    <th
                      scope="col"
                      class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-100"
                    >
                      Date
                    </th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200 dark:divide-zinc-800 bg-white dark:bg-zinc-900">
                  <tr :for={app <- @applications} class="hover:bg-gray-50 dark:hover:bg-zinc-800/50">
                    <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 dark:text-gray-100 sm:pl-6">
                      {app.full_name}
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                      {app.country}
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                      {app.monthly_income}
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                      {app.amount_requested}
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm">
                      <span class={[
                        "inline-flex items-center rounded-md px-2 py-1 text-xs font-medium ring-1 ring-inset",
                        app.status == :approved &&
                          "bg-green-50 text-green-700 ring-green-600/20 dark:bg-green-900/30 dark:text-green-400",
                        app.status == :rejected &&
                          "bg-red-50 text-red-700 ring-red-600/10 dark:bg-red-900/30 dark:text-red-400",
                        app.status == :pending &&
                          "bg-yellow-50 text-yellow-800 ring-yellow-600/20 dark:bg-yellow-900/30 dark:text-yellow-400"
                      ]}>
                        {app.status}
                      </span>
                    </td>
                    <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500 dark:text-gray-400">
                      {Calendar.strftime(app.inserted_at, "%Y-%m-%d %H:%M")}
                    </td>
                  </tr>
                  <tr :if={Enum.empty?(@applications)}>
                    <td
                      colspan="6"
                      class="py-10 text-center text-sm text-gray-500 dark:text-gray-400 italic"
                    >
                      No applications found.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
