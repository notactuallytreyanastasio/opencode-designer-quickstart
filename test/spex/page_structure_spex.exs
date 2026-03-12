Path.wildcard("_build/test/lib/*/ebin") |> Enum.each(&Code.prepend_path/1)
Application.ensure_all_started(:design_system_showoff)

defmodule DesignSystemShowoff.Spex.PageStructureSpex do
  use SexySpex

  @endpoint DesignSystemShowoffWeb.Endpoint
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  use DesignSystemShowoffWeb, :verified_routes

  setup do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(DesignSystemShowoff.Repo, shared: true)
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: build_conn()}
  end

  spex "Showcase page contains all 5 component sections" do
    scenario "every component has its own section on the page", context do
      given_ "the designer opens the showcase page", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the page wrapper is rendered", context do
        assert has_element?(context.view, "#showcase-page")
        context
      end

      and_ "the KPI tile section is present", context do
        assert has_element?(context.view, "#kpi-tile-section")
        context
      end

      and_ "the datepicker section is present", context do
        assert has_element?(context.view, "#datepicker-section")
        context
      end

      and_ "the loading button section is present", context do
        assert has_element?(context.view, "#loading-button-section")
        context
      end

      and_ "the product search bar section is present", context do
        assert has_element?(context.view, "#product-search-bar-section")
        context
      end

      and_ "the data table section is present", context do
        assert has_element?(context.view, "#data-table-section")
        context
      end
    end
  end
end
