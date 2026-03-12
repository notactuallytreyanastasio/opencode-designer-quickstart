defmodule DesignSystemShowoffWeb.Components.KpiTile do
  use Phoenix.Component

  import DesignSystemShowoffWeb.CoreComponents, only: [icon: 1]

  @doc """
  A KPI tile for displaying a key metric with optional trend indicator and subtext.

  Used for scenario modeling dashboards with marketing and sales data.
  """

  attr :id, :string, required: true, doc: "Unique DOM id for the tile"
  attr :title, :string, required: true, doc: "Metric label displayed above the value"
  attr :value, :string, required: true, doc: "Pre-formatted metric value (e.g. \"$46M\", \"8\")"
  attr :trend, :atom, default: nil, doc: "Optional trend direction — :up, :down, or nil"
  attr :subtext, :string, default: nil, doc: "Optional explanatory text below the value"
  attr :border_color, :string, default: nil, doc: "Optional CSS color for the full card border"

  def kpi_tile(assigns) do
    ~H"""
    <div
      id={@id}
      class="bg-base-100 rounded-xl border border-base-300 px-5 py-4"
      style={tile_style(@border_color)}
    >
      <div id={"#{@id}-title"} class="text-sm font-medium text-base-content/60 mb-2">
        {@title}
      </div>

      <div class="flex items-center gap-2">
        <%= if @trend do %>
          <div id={"#{@id}-trend"}>
            <span class={trend_color(@trend)}>
              <.icon name={trend_icon(@trend)} class="size-5" />
            </span>
          </div>
        <% end %>

        <div id={"#{@id}-value"} class="text-3xl font-bold text-base-content tracking-tight">
          {@value}
        </div>
      </div>

      <%= if @subtext do %>
        <div
          id={"#{@id}-subtext"}
          class={["text-sm font-medium mt-1", subtext_color(@trend)]}
        >
          {@subtext}
        </div>
      <% end %>
    </div>
    """
  end

  defp trend_icon(:up), do: "hero-arrow-up-right"
  defp trend_icon(:down), do: "hero-arrow-down-left"

  defp trend_color(:up), do: "text-success"
  defp trend_color(:down), do: "text-error"

  defp subtext_color(:up), do: "text-success"
  defp subtext_color(:down), do: "text-error"
  defp subtext_color(_), do: "text-base-content/60"

  defp tile_style(nil),
    do: "box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);"

  defp tile_style(color),
    do:
      "border-color: #{color}; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -2px rgba(0,0,0,0.1);"
end
