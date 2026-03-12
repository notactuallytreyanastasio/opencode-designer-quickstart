defmodule DesignSystemShowoffWeb.Components.ProductSearchBar do
  use Phoenix.Component

  import DesignSystemShowoffWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :search_query, :string, default: ""
  attr :selected_products, :list, default: []
  attr :search_suggestions, :list, default: []
  attr :show_dropdown, :boolean, default: false
  attr :placeholder, :string, default: "Search grocery items..."
  attr :background_color, :string, default: "#FF00FF"
  attr :pill_color, :string, default: "#89CFF0"

  def product_search_bar(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-lg">
      <div class="card-body">
        <div
          id={@id}
          class="relative flex items-center gap-2 rounded-lg px-3 py-2 min-h-[44px]"
          style={"background-color: #{@background_color}"}
        >
          <%!-- Search Icon --%>
          <span id={"#{@id}-icon"} class="shrink-0">
            <.icon name="hero-magnifying-glass" class="size-5 text-white" />
          </span>

          <%!-- Pills + Input area --%>
          <div
            id={"#{@id}-pills"}
            class="flex flex-wrap items-center gap-1.5 flex-1 min-w-0"
          >
            <%!-- Selected product pills --%>
            <span
              :for={product <- @selected_products}
              id={"#{@id}-pill-#{product.id}"}
              class="inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-medium text-gray-900"
              style={"background-color: #{@pill_color}"}
            >
              {product.name}
              <button
                id={"#{@id}-remove-#{product.id}"}
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
              id={"#{@id}-input"}
              type="text"
              placeholder={@placeholder}
              value={@search_query}
              phx-keyup="search-products"
              autocomplete="off"
              class="flex-1 min-w-[120px] bg-transparent border-none outline-none text-white placeholder-white/60 text-sm focus:ring-0 p-0"
            />
          </div>

          <%!-- Filter Icon --%>
          <span id={"#{@id}-filter-icon"} class="shrink-0">
            <.icon name="hero-funnel" class="size-5 text-white" />
          </span>

          <%!-- Autocomplete Dropdown --%>
          <div
            :if={@show_dropdown}
            id={"#{@id}-dropdown"}
            class="absolute left-0 right-0 top-full mt-1 bg-base-100 rounded-lg shadow-lg border border-base-300 z-50 max-h-60 overflow-y-auto"
          >
            <button
              :for={suggestion <- @search_suggestions}
              id={"#{@id}-suggestion-#{suggestion.id}"}
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
    """
  end
end
