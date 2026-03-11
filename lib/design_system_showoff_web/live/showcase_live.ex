defmodule DesignSystemShowoffWeb.ShowcaseLive do
  use DesignSystemShowoffWeb, :live_view

  @stub_table_data [
    %{id: 1, name: "Alice Johnson", role: "Designer", status: "Active"},
    %{id: 2, name: "Bob Smith", role: "Developer", status: "Away"},
    %{id: 3, name: "Carol White", role: "PM", status: "Active"},
    %{id: 4, name: "Dan Brown", role: "Designer", status: "Offline"},
    %{id: 5, name: "Eve Davis", role: "Developer", status: "Active"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    today = Date.utc_today()

    socket =
      socket
      |> assign(:page_title, "Component Showcase")
      |> assign(:current_month, Date.beginning_of_month(today))
      |> assign(:selected_date, nil)
      |> assign(:calendar_weeks, calendar_weeks(Date.beginning_of_month(today)))
      |> assign(:loading, false)
      |> assign(:table_data, @stub_table_data)

    {:ok, socket}
  end

  @impl true
  def handle_event("select-date", %{"date" => date_string}, socket) do
    date = Date.from_iso8601!(date_string)
    {:noreply, assign(socket, :selected_date, date)}
  end

  def handle_event("prev-month", _params, socket) do
    new_month = socket.assigns.current_month |> Date.add(-1) |> Date.beginning_of_month()

    socket =
      socket
      |> assign(:current_month, new_month)
      |> assign(:calendar_weeks, calendar_weeks(new_month))

    {:noreply, socket}
  end

  def handle_event("next-month", _params, socket) do
    new_month = socket.assigns.current_month |> Date.end_of_month() |> Date.add(1)

    socket =
      socket
      |> assign(:current_month, new_month)
      |> assign(:calendar_weeks, calendar_weeks(new_month))

    {:noreply, socket}
  end

  def handle_event("start-loading", _params, socket) do
    {:noreply, assign(socket, :loading, true)}
  end

  def handle_event("reset-loading", _params, socket) do
    {:noreply, assign(socket, :loading, false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div id="showcase-page" class="space-y-12">
        <div class="text-center">
          <h1 class="text-3xl font-bold tracking-tight">Component Showcase</h1>
          <p class="mt-2 text-base-content/60">
            A living gallery of design system components
          </p>
        </div>

        <%!-- Datepicker Section --%>
        <section id="datepicker-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Calendar Datepicker
          </h2>
          <div id="datepicker" class="card bg-base-200 shadow-lg">
            <div class="card-body">
              <%!-- Month Navigation --%>
              <div class="flex items-center justify-between mb-4">
                <button
                  id="datepicker-prev-month"
                  phx-click="prev-month"
                  class="btn btn-ghost btn-sm btn-circle"
                >
                  <.icon name="hero-chevron-left" class="size-5" />
                </button>
                <span id="datepicker-month-label" class="text-lg font-semibold">
                  {Calendar.strftime(@current_month, "%B %Y")}
                </span>
                <button
                  id="datepicker-next-month"
                  phx-click="next-month"
                  class="btn btn-ghost btn-sm btn-circle"
                >
                  <.icon name="hero-chevron-right" class="size-5" />
                </button>
              </div>

              <%!-- Weekday Headers --%>
              <div id="datepicker-weekday-headers" class="grid grid-cols-7 gap-1 text-center mb-2">
                <div
                  :for={day <- ~w(Sun Mon Tue Wed Thu Fri Sat)}
                  class="text-xs font-medium text-base-content/50"
                >
                  {day}
                </div>
              </div>

              <%!-- Calendar Grid --%>
              <div id="datepicker-grid" class="grid grid-cols-7 gap-1">
                <%= for week <- @calendar_weeks do %>
                  <%= for day <- week do %>
                    <%= if day do %>
                      <button
                        id={"datepicker-day-#{day}"}
                        phx-click="select-date"
                        phx-value-date={Date.to_iso8601(day)}
                        class={[
                          "btn btn-sm btn-ghost",
                          day == Date.utc_today() && "btn-outline btn-primary",
                          @selected_date == day && "btn-active btn-primary",
                          day.month != @current_month.month && "opacity-30"
                        ]}
                      >
                        {day.day}
                      </button>
                    <% else %>
                      <div></div>
                    <% end %>
                  <% end %>
                <% end %>
              </div>

              <%!-- Selected Date Display --%>
              <div
                :if={@selected_date}
                id="datepicker-selected-date"
                class="mt-4 text-center text-sm font-medium text-primary"
              >
                {Calendar.strftime(@selected_date, "%B %d, %Y")}
              </div>
            </div>
          </div>
        </section>

        <%!-- Loading Button Section --%>
        <section id="loading-button-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Loading Button
          </h2>
          <div class="card bg-base-200 shadow-lg">
            <div class="card-body flex flex-row items-center gap-4">
              <button
                id="loading-button"
                phx-click="start-loading"
                class={[
                  "btn btn-primary",
                  @loading && "btn-disabled"
                ]}
                disabled={@loading}
              >
                <span
                  :if={@loading}
                  id="loading-button-spinner"
                  class="loading loading-spinner loading-sm"
                >
                </span>
                {if @loading, do: "Loading", else: "Submit"}
              </button>

              <button
                :if={@loading}
                id="loading-button-reset"
                phx-click="reset-loading"
                class="btn btn-ghost btn-sm"
              >
                Reset
              </button>
            </div>
          </div>
        </section>

        <%!-- Data Table Section --%>
        <section id="data-table-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Data Table
          </h2>
          <div class="card bg-base-200 shadow-lg overflow-x-auto">
            <table id="data-table" class="table table-zebra">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Role</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={row <- @table_data} id={"data-table-row-#{row.id}"}>
                  <td class="font-medium">{row.name}</td>
                  <td>{row.role}</td>
                  <td>
                    <span class={[
                      "badge",
                      badge_class(row.status)
                    ]}>
                      {row.status}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  # -- Private helpers --

  defp badge_class("Active"), do: "badge-success"
  defp badge_class("Away"), do: "badge-warning"
  defp badge_class("Offline"), do: "badge-ghost"
  defp badge_class(_), do: "badge-neutral"

  defp calendar_weeks(first_of_month) do
    last_of_month = Date.end_of_month(first_of_month)

    # Day of week: 1 = Monday ... 7 = Sunday
    # We want Sunday = 0 for our grid
    start_dow = Date.day_of_week(first_of_month, :sunday) - 1
    end_dow = Date.day_of_week(last_of_month, :sunday) - 1

    # Build list of days with leading/trailing nils for alignment
    leading_nils = List.duplicate(nil, start_dow)
    trailing_nils = List.duplicate(nil, 6 - end_dow)

    days =
      Date.range(first_of_month, last_of_month)
      |> Enum.to_list()

    all_cells = leading_nils ++ days ++ trailing_nils

    Enum.chunk_every(all_cells, 7)
  end
end
