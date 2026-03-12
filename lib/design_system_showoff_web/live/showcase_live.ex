defmodule DesignSystemShowoffWeb.ShowcaseLive do
  use DesignSystemShowoffWeb, :live_view

  @stub_table_data [
    %{id: 1, name: "Alice Johnson", role: "Designer", status: "Active"},
    %{id: 2, name: "Bob Smith", role: "Developer", status: "Away"},
    %{id: 3, name: "Carol White", role: "PM", status: "Active"},
    %{id: 4, name: "Dan Brown", role: "Designer", status: "Offline"},
    %{id: 5, name: "Eve Davis", role: "Developer", status: "Active"}
  ]

  @stub_metrics [
    %{
      id: 1,
      name: "Transacting Omni POS",
      value: 593_244,
      trend: :up,
      trend_pct: 12.5,
      accent_color: "#FF00FF"
    },
    %{
      id: 2,
      name: "Monthly Revenue",
      value: 1_284_930,
      trend: :up,
      trend_pct: 8.3,
      accent_color: "#89CFF0"
    },
    %{
      id: 3,
      name: "Avg. Order Value",
      value: 74,
      trend: :down,
      trend_pct: 3.1,
      accent_color: "#FF00FF"
    },
    %{
      id: 4,
      name: "Returns Processed",
      value: 2_847,
      trend: :down,
      trend_pct: 5.7,
      accent_color: "#89CFF0"
    }
  ]

  @stub_grocery_items [
    %{id: 1, name: "Organic Bananas"},
    %{id: 2, name: "Whole Milk"},
    %{id: 3, name: "Sourdough Bread"},
    %{id: 4, name: "Avocados"},
    %{id: 5, name: "Free Range Eggs"},
    %{id: 6, name: "Olive Oil"},
    %{id: 7, name: "Cherry Tomatoes"},
    %{id: 8, name: "Greek Yogurt"},
    %{id: 9, name: "Sparkling Water"}
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
      |> assign(:metrics, @stub_metrics)
      |> assign(:grocery_items, @stub_grocery_items)
      |> assign(:search_query, "")
      |> assign(:search_suggestions, [])
      |> assign(:selected_products, [])
      |> assign(:show_dropdown, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("search-products", %{"value" => query}, socket) do
    query = String.trim(query)

    if query == "" do
      {:noreply,
       socket
       |> assign(:search_query, "")
       |> assign(:search_suggestions, [])
       |> assign(:show_dropdown, false)}
    else
      selected_ids = Enum.map(socket.assigns.selected_products, & &1.id)

      suggestions =
        socket.assigns.grocery_items
        |> Enum.reject(fn item -> item.id in selected_ids end)
        |> Enum.filter(fn item ->
          String.contains?(String.downcase(item.name), String.downcase(query))
        end)

      {:noreply,
       socket
       |> assign(:search_query, query)
       |> assign(:search_suggestions, suggestions)
       |> assign(:show_dropdown, suggestions != [])}
    end
  end

  def handle_event("select-product", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)

    item = Enum.find(socket.assigns.grocery_items, fn item -> item.id == id end)

    if item do
      {:noreply,
       socket
       |> assign(:selected_products, socket.assigns.selected_products ++ [item])
       |> assign(:search_query, "")
       |> assign(:search_suggestions, [])
       |> assign(:show_dropdown, false)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("remove-product", %{"id" => id_str}, socket) do
    id = String.to_integer(id_str)

    updated = Enum.reject(socket.assigns.selected_products, fn item -> item.id == id end)

    {:noreply, assign(socket, :selected_products, updated)}
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

        <%!-- Metric Tile Section --%>
        <section id="metric-tile-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Metric Tiles
          </h2>
          <div id="metric-tile-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div
              :for={metric <- @metrics}
              id={"metric-tile-#{metric.id}"}
              class="bg-base-100 rounded-lg shadow-sm border border-base-300 px-5 py-4"
              style={"border-left: 4px solid #{metric.accent_color}; border-left-color: #{metric.accent_color};"}
            >
              <div
                id={"metric-tile-name-#{metric.id}"}
                class="text-sm font-medium text-base-content/60 mb-1"
              >
                {metric.name}
              </div>
              <div
                id={"metric-tile-value-#{metric.id}"}
                class="text-2xl font-bold text-base-content tracking-tight"
              >
                {format_metric_value(metric.value)}
              </div>
              <div
                id={"metric-tile-trend-#{metric.id}"}
                class={[
                  "flex items-center gap-1 mt-2 text-sm font-medium",
                  if(metric.trend == :up, do: "text-success", else: "text-error")
                ]}
              >
                <%= if metric.trend == :up do %>
                  <.icon name="hero-arrow-trending-up" class="size-4" />
                <% else %>
                  <.icon name="hero-arrow-trending-down" class="size-4" />
                <% end %>
                <span>{metric.trend_pct}%</span>
              </div>
            </div>
          </div>
        </section>

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

        <%!-- Product Search Bar Section --%>
        <section id="product-search-bar-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Product Search Bar
          </h2>
          <div class="card bg-base-200 shadow-lg">
            <div class="card-body">
              <div
                id="product-search-bar"
                class="relative flex items-center gap-2 rounded-lg px-3 py-2 min-h-[44px]"
                style="background-color: #FF00FF"
              >
                <%!-- Search Icon --%>
                <span id="product-search-bar-icon" class="shrink-0">
                  <.icon name="hero-magnifying-glass" class="size-5 text-white" />
                </span>

                <%!-- Pills + Input area --%>
                <div
                  id="product-search-bar-pills"
                  class="flex flex-wrap items-center gap-1.5 flex-1 min-w-0"
                >
                  <%!-- Selected product pills --%>
                  <span
                    :for={product <- @selected_products}
                    id={"product-search-bar-pill-#{product.id}"}
                    class="inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-medium text-gray-900"
                    style="background-color: #89CFF0"
                  >
                    {product.name}
                    <button
                      id={"product-search-bar-remove-#{product.id}"}
                      phx-click="remove-product"
                      phx-value-id={product.id}
                      type="button"
                      class="ml-0.5 inline-flex items-center justify-center size-4 rounded-full hover:bg-black/10 cursor-pointer"
                    >
                      <.icon name="hero-x-mark" class="size-3" />
                    </button>
                  </span>

                  <%!-- Search input --%>
                  <input
                    id="product-search-bar-input"
                    type="text"
                    placeholder="Search grocery items..."
                    value={@search_query}
                    phx-keyup="search-products"
                    autocomplete="off"
                    class="flex-1 min-w-[120px] bg-transparent border-none outline-none text-white placeholder-white/60 text-sm focus:ring-0 p-0"
                  />
                </div>

                <%!-- Filter Icon --%>
                <span id="product-search-bar-filter-icon" class="shrink-0">
                  <.icon name="hero-funnel" class="size-5 text-white" />
                </span>

                <%!-- Autocomplete Dropdown --%>
                <div
                  :if={@show_dropdown}
                  id="product-search-bar-dropdown"
                  class="absolute left-0 right-0 top-full mt-1 bg-base-100 rounded-lg shadow-lg border border-base-300 z-50 max-h-60 overflow-y-auto"
                >
                  <button
                    :for={suggestion <- @search_suggestions}
                    id={"product-search-bar-suggestion-#{suggestion.id}"}
                    phx-click="select-product"
                    phx-value-id={suggestion.id}
                    type="button"
                    class="w-full text-left px-4 py-2 text-sm hover:bg-base-200 cursor-pointer transition-colors first:rounded-t-lg last:rounded-b-lg"
                  >
                    {suggestion.name}
                  </button>
                </div>
              </div>
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

  defp format_metric_value(value) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end

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
