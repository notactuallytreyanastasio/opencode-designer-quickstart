defmodule DesignSystemShowoffWeb.Components.DataTable do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :rows, :list, required: true

  slot :col, required: true, doc: "Column definitions with label and custom rendering" do
    attr :key, :atom, required: true
    attr :label, :string, required: true
  end

  def data_table(assigns) do
    ~H"""
    <div class="card bg-base-200 shadow-lg overflow-x-auto">
      <table id={@id} class="table table-zebra">
        <thead>
          <tr>
            <th :for={col <- @col}>{col.label}</th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @rows} id={"#{@id}-row-#{row.id}"}>
            <td :for={col <- @col}>
              {render_slot(col, row)}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
