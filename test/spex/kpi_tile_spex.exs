Path.wildcard("_build/test/lib/*/ebin") |> Enum.each(&Code.prepend_path/1)
Application.ensure_all_started(:design_system_showoff)

defmodule DesignSystemShowoff.Spex.KpiTileSpex do
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

  # Stub data plan:
  #
  # Row 1 — with custom border colors:
  # Tile 1: "Active Projects"    | value: "8"    | trend: :up   | subtext: "+2 this week"       | border: #22c55e (green)
  # Tile 2: "Total Opportunity"  | value: "$46M" | trend: :down | subtext: "2% identified"      | border: #ef4444 (red)
  # Tile 3: "Active Scenarios"   | value: "12"   | trend: nil   | subtext: "of 12 completed"    | border: #3b82f6 (blue)
  # Tile 4: "Applied to Budget"  | value: "8"    | no trend     | no subtext                    | no border color
  #
  # Row 2 — no border colors (all default borders):
  # Tile 5: "Win Rate"           | value: "34%"    | trend: :up   | subtext: "+5% vs last quarter" | no border
  # Tile 6: "Pipeline Value"     | value: "$12.8M" | trend: :down | subtext: "-$1.2M this month"   | no border
  # Tile 7: "Avg Deal Size"      | value: "$285K"  | trend: nil   | subtext: "across 45 deals"     | no border
  # Tile 8: "Days to Close"      | value: "42"     | trend: nil   | no subtext                     | no border

  spex "KPI Tile displays key metrics with optional trend arrows and subtext" do
    # -- Core Display --

    scenario "renders with just a title and metric value (minimum props)", context do
      given_ "the designer opens the showcase page", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the minimal tile shows its title", context do
        assert has_element?(context.view, "#kpi-tile-4")
        assert has_element?(context.view, "#kpi-tile-4-title", "Applied to Budget")
        context
      end

      and_ "it shows its metric value", context do
        assert has_element?(context.view, "#kpi-tile-4-value", "8")
        context
      end
    end

    scenario "metric value is displayed large and prominent", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the value element uses large text styling", context do
        assert has_element?(context.view, "#kpi-tile-1-value.text-3xl")
        context
      end
    end

    scenario "title is smaller and positioned above the metric", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the title uses small text styling", context do
        assert has_element?(context.view, "#kpi-tile-1-title.text-sm")
        context
      end

      and_ "the title shows the metric name", context do
        assert has_element?(context.view, "#kpi-tile-1-title", "Active Projects")
        context
      end
    end

    # -- Trend Indicator (optional) --

    scenario "shows upward arrow in green when trend is :up", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the trend area contains a green up-right arrow icon", context do
        assert has_element?(context.view, "#kpi-tile-1-trend .text-success")
        assert has_element?(context.view, "#kpi-tile-1-trend .hero-arrow-up-right")
        context
      end
    end

    scenario "shows downward arrow in red when trend is :down", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the trend area contains a red down-left arrow icon", context do
        assert has_element?(context.view, "#kpi-tile-2-trend .text-error")
        assert has_element?(context.view, "#kpi-tile-2-trend .hero-arrow-down-left")
        context
      end
    end

    scenario "no arrow shown when trend is not provided", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the minimal tile has no trend element at all", context do
        refute has_element?(context.view, "#kpi-tile-4-trend")
        context
      end
    end

    # -- Subtext (optional) --

    scenario "displays subtext below the metric when provided", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the first tile shows its subtext", context do
        assert has_element?(context.view, "#kpi-tile-1-subtext", "+2 this week")
        context
      end
    end

    scenario "subtext is green when trend is :up", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the subtext uses the success color class", context do
        assert has_element?(context.view, "#kpi-tile-1-subtext.text-success")
        context
      end
    end

    scenario "subtext is red when trend is :down", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the subtext uses the error color class", context do
        assert has_element?(context.view, "#kpi-tile-2-subtext.text-error")
        context
      end
    end

    scenario "subtext uses neutral color when no trend is set", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the subtext uses a muted neutral color", context do
        # Tile 3 has subtext "of 12 completed" but no trend
        assert has_element?(context.view, "#kpi-tile-3-subtext.text-base-content\\/60")
        context
      end
    end

    scenario "no subtext shown when not provided", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the minimal tile has no subtext element", context do
        refute has_element?(context.view, "#kpi-tile-4-subtext")
        context
      end
    end

    # -- Drop Shadow --

    scenario "every tile has a 4px drop shadow", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "a tile with a custom border has the shadow style", context do
        assert has_element?(context.view, "#kpi-tile-1[style*='box-shadow']")
        context
      end

      and_ "a tile without a custom border also has the shadow style", context do
        assert has_element?(context.view, "#kpi-tile-4[style*='box-shadow']")
        context
      end
    end

    # -- Border Customization --

    scenario "full border accepts a custom color", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the tile border uses the custom color from the prop", context do
        assert has_element?(context.view, "#kpi-tile-1[style*='border-color: #22c55e']")
        context
      end
    end

    scenario "falls back to subtle default border when no color specified", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "the tile renders without an inline border-color style", context do
        assert has_element?(context.view, "#kpi-tile-4")
        refute has_element?(context.view, "#kpi-tile-4[style*='border-color']")
        context
      end
    end

    # -- Second Row: Borderless Tiles --

    scenario "second row tile 5 renders with trend up and no border", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "tile 5 shows Win Rate title and value", context do
        assert has_element?(context.view, "#kpi-tile-5-title", "Win Rate")
        assert has_element?(context.view, "#kpi-tile-5-value", "34%")
        context
      end

      and_ "tile 5 has an upward trend arrow", context do
        assert has_element?(context.view, "#kpi-tile-5-trend .text-success")
        context
      end

      and_ "tile 5 shows its subtext", context do
        assert has_element?(context.view, "#kpi-tile-5-subtext", "+5% vs last quarter")
        context
      end

      and_ "tile 5 has no custom border color", context do
        refute has_element?(context.view, "#kpi-tile-5[style*='border-color']")
        context
      end
    end

    scenario "second row tile 6 renders with trend down and no border", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "tile 6 shows Pipeline Value title and value", context do
        assert has_element?(context.view, "#kpi-tile-6-title", "Pipeline Value")
        assert has_element?(context.view, "#kpi-tile-6-value", "$12.8M")
        context
      end

      and_ "tile 6 has a downward trend arrow", context do
        assert has_element?(context.view, "#kpi-tile-6-trend .text-error")
        context
      end

      and_ "tile 6 shows its subtext in red", context do
        assert has_element?(context.view, "#kpi-tile-6-subtext.text-error", "-$1.2M this month")
        context
      end
    end

    scenario "second row tile 7 renders with subtext but no trend", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "tile 7 shows Avg Deal Size title and value", context do
        assert has_element?(context.view, "#kpi-tile-7-title", "Avg Deal Size")
        assert has_element?(context.view, "#kpi-tile-7-value", "$285K")
        context
      end

      and_ "tile 7 has no trend arrow", context do
        refute has_element?(context.view, "#kpi-tile-7-trend")
        context
      end

      and_ "tile 7 shows neutral subtext", context do
        assert has_element?(
                 context.view,
                 "#kpi-tile-7-subtext.text-base-content\\/60",
                 "across 45 deals"
               )

        context
      end
    end

    scenario "second row tile 8 is the most minimal — no trend, no subtext, no border", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "tile 8 shows Days to Close title and value", context do
        assert has_element?(context.view, "#kpi-tile-8-title", "Days to Close")
        assert has_element?(context.view, "#kpi-tile-8-value", "42")
        context
      end

      and_ "tile 8 has no trend arrow", context do
        refute has_element?(context.view, "#kpi-tile-8-trend")
        context
      end

      and_ "tile 8 has no subtext", context do
        refute has_element?(context.view, "#kpi-tile-8-subtext")
        context
      end

      and_ "tile 8 has no custom border color", context do
        refute has_element?(context.view, "#kpi-tile-8[style*='border-color']")
        context
      end
    end

    scenario "every second-row tile also has a drop shadow", context do
      given_ "the showcase page is loaded", context do
        {:ok, view, _html} = live(context.conn, ~p"/showcase")
        Map.put(context, :view, view)
      end

      then_ "tile 5 has the shadow style", context do
        assert has_element?(context.view, "#kpi-tile-5[style*='box-shadow']")
        context
      end

      and_ "tile 8 has the shadow style too", context do
        assert has_element?(context.view, "#kpi-tile-8[style*='box-shadow']")
        context
      end
    end
  end
end
