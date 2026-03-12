defmodule DesignSystemShowoffWeb.ShowcaseLive do
  use DesignSystemShowoffWeb, :live_view

  import DesignSystemShowoffWeb.Components.MetricTile
  import DesignSystemShowoffWeb.Components.CalendarDatepicker
  import DesignSystemShowoffWeb.Components.LoadingButton
  import DesignSystemShowoffWeb.Components.ProductSearchBar
  import DesignSystemShowoffWeb.Components.DataTable

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
            <.metric_tile
              :for={metric <- @metrics}
              id={"metric-tile-#{metric.id}"}
              item_id={metric.id}
              name={metric.name}
              value={metric.value}
              trend={metric.trend}
              trend_pct={metric.trend_pct}
              accent_color={metric.accent_color}
            />
          </div>
        </section>

        <%!-- Datepicker Section --%>
        <section id="datepicker-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Calendar Datepicker
          </h2>
          <.calendar_datepicker
            id="datepicker"
            current_month={@current_month}
            selected_date={@selected_date}
            calendar_weeks={@calendar_weeks}
          />
        </section>

        <%!-- Loading Button Section --%>
        <section id="loading-button-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Loading Button
          </h2>
          <.loading_button id="loading-button" loading={@loading} />
        </section>

        <%!-- Product Search Bar Section --%>
        <section id="product-search-bar-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Product Search Bar
          </h2>
          <.product_search_bar
            id="product-search-bar"
            search_query={@search_query}
            selected_products={@selected_products}
            search_suggestions={@search_suggestions}
            show_dropdown={@show_dropdown}
          />
        </section>

        <%!-- Data Table Section --%>
        <section id="data-table-section" class="space-y-4">
          <h2 class="text-xl font-semibold border-b border-base-300 pb-2">
            Data Table
          </h2>
          <.data_table id="data-table" rows={@table_data}>
            <:col :let={row} key={:name} label="Name">
              <span class="font-medium">{row.name}</span>
            </:col>
            <:col :let={row} key={:role} label="Role">
              {row.role}
            </:col>
            <:col :let={row} key={:status} label="Status">
              <span class={["badge", badge_class(row.status)]}>
                {row.status}
              </span>
            </:col>
          </.data_table>
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

    start_dow = Date.day_of_week(first_of_month, :sunday) - 1
    end_dow = Date.day_of_week(last_of_month, :sunday) - 1

    leading_nils = List.duplicate(nil, start_dow)
    trailing_nils = List.duplicate(nil, 6 - end_dow)

    days =
      Date.range(first_of_month, last_of_month)
      |> Enum.to_list()

    all_cells = leading_nils ++ days ++ trailing_nils

    Enum.chunk_every(all_cells, 7)
  end
end
