defmodule DesignSystemShowoffWeb.Components.CalendarDatepicker do
  use Phoenix.Component

  import DesignSystemShowoffWeb.CoreComponents, only: [icon: 1]

  attr :id, :string, required: true
  attr :current_month, Date, required: true
  attr :selected_date, Date, default: nil
  attr :calendar_weeks, :list, required: true

  def calendar_datepicker(assigns) do
    ~H"""
    <div id={@id} class="card bg-base-200 shadow-lg">
      <div class="card-body">
        <%!-- Month Navigation --%>
        <div class="flex items-center justify-between mb-4">
          <button
            id={"#{@id}-prev-month"}
            phx-click="prev-month"
            class="btn btn-ghost btn-sm btn-circle"
          >
            <.icon name="hero-chevron-left" class="size-5" />
          </button>
          <span id={"#{@id}-month-label"} class="text-lg font-semibold">
            {Calendar.strftime(@current_month, "%B %Y")}
          </span>
          <button
            id={"#{@id}-next-month"}
            phx-click="next-month"
            class="btn btn-ghost btn-sm btn-circle"
          >
            <.icon name="hero-chevron-right" class="size-5" />
          </button>
        </div>

        <%!-- Weekday Headers --%>
        <div id={"#{@id}-weekday-headers"} class="grid grid-cols-7 gap-1 text-center mb-2">
          <div
            :for={day <- ~w(Sun Mon Tue Wed Thu Fri Sat)}
            class="text-xs font-medium text-base-content/50"
          >
            {day}
          </div>
        </div>

        <%!-- Calendar Grid --%>
        <div id={"#{@id}-grid"} class="grid grid-cols-7 gap-1">
          <%= for week <- @calendar_weeks do %>
            <%= for day <- week do %>
              <%= if day do %>
                <button
                  id={"#{@id}-day-#{day}"}
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
          id={"#{@id}-selected-date"}
          class="mt-4 text-center text-sm font-medium text-primary"
        >
          {Calendar.strftime(@selected_date, "%B %d, %Y")}
        </div>
      </div>
    </div>
    """
  end
end
