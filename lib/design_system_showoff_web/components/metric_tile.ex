defmodule DesignSystemShowoffWeb.Components.MetricTile do
  use Phoenix.Component

  import DesignSystemShowoffWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :item_id, :any, required: true, doc: "Unique identifier for sub-element IDs"
  attr :name, :string, required: true
  attr :value, :integer, required: true
  attr :trend, :atom, values: [:up, :down], required: true
  attr :trend_pct, :float, required: true
  attr :accent_color, :string, default: "#FF00FF"

  def metric_tile(assigns) do
    ~H"""
    <div
      id={@id}
      class="bg-base-100 rounded-lg shadow-sm border border-base-300 px-5 py-4"
      style={"border-left: 4px solid #{@accent_color}; border-left-color: #{@accent_color};"}
    >
      <div
        id={"metric-tile-name-#{@item_id}"}
        class="text-sm font-medium text-base-content/60 mb-1"
      >
        {@name}
      </div>
      <div
        id={"metric-tile-value-#{@item_id}"}
        class="text-2xl font-bold text-base-content tracking-tight"
      >
        {format_metric_value(@value)}
      </div>
      <div
        id={"metric-tile-trend-#{@item_id}"}
        class={[
          "flex items-center gap-1 mt-2 text-sm font-medium",
          if(@trend == :up, do: "text-success", else: "text-error")
        ]}
      >
        <%= if @trend == :up do %>
          <.icon name="hero-arrow-trending-up" class="size-4" />
        <% else %>
          <.icon name="hero-arrow-trending-down" class="size-4" />
        <% end %>
        <span>{@trend_pct}%</span>
      </div>
    </div>
    """
  end

  defp format_metric_value(value) when is_integer(value) do
    value
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
end
