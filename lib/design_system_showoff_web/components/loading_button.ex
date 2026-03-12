defmodule DesignSystemShowoffWeb.Components.LoadingButton do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :loading, :boolean, default: false
  attr :label, :string, default: "Submit"
  attr :loading_label, :string, default: "Loading"
  attr :on_click, :string, default: "start-loading"
  attr :on_reset, :string, default: "reset-loading"

  def loading_button(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-lg">
      <div class="card-body flex flex-row items-center gap-4">
        <button
          id={@id}
          phx-click={@on_click}
          class={[
            "btn btn-primary",
            @loading && "btn-disabled"
          ]}
          disabled={@loading}
        >
          <span
            :if={@loading}
            id={"#{@id}-spinner"}
            class="loading loading-spinner loading-sm"
          >
          </span>
          {if @loading, do: @loading_label, else: @label}
        </button>

        <button
          :if={@loading}
          id={"#{@id}-reset"}
          phx-click={@on_reset}
          class="btn btn-ghost btn-sm"
        >
          Reset
        </button>
      </div>
    </div>
    """
  end
end
