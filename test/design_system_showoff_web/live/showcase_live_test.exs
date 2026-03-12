defmodule DesignSystemShowoffWeb.ShowcaseLiveTest do
  use DesignSystemShowoffWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "ShowcaseLive page structure" do
    test "renders the showcase page with all 5 component sections", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # The page should have a title/header
      assert has_element?(view, "#showcase-page")

      # All 5 component sections should be present
      assert has_element?(view, "#kpi-tile-section")
      assert has_element?(view, "#datepicker-section")
      assert has_element?(view, "#loading-button-section")
      assert has_element?(view, "#product-search-bar-section")
      assert has_element?(view, "#data-table-section")
    end
  end

  describe "Calendar Datepicker" do
    test "renders the datepicker with current month and year", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Should show the calendar container
      assert has_element?(view, "#datepicker")

      # Should display the current month and year in the header
      today = Date.utc_today()
      month_name = Calendar.strftime(today, "%B %Y")
      assert has_element?(view, "#datepicker-month-label", month_name)
    end

    test "renders day-of-week headers", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Should show day-of-week column headers
      assert has_element?(view, "#datepicker-weekday-headers")
    end

    test "renders calendar grid with day cells", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Should have a grid of day buttons
      assert has_element?(view, "#datepicker-grid")

      # Today should be visually highlighted
      today = Date.utc_today()
      assert has_element?(view, "#datepicker-day-#{today}")
    end

    test "allows selecting a date", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      today = Date.utc_today()

      # Click on today's date
      view |> element("#datepicker-day-#{today}") |> render_click()

      # The selected date should be displayed
      assert has_element?(
               view,
               "#datepicker-selected-date",
               Calendar.strftime(today, "%B %d, %Y")
             )
    end

    test "can navigate to previous month", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Click previous month button
      view |> element("#datepicker-prev-month") |> render_click()

      # Should now show the previous month
      prev_month = Date.utc_today() |> Date.beginning_of_month() |> Date.add(-1)
      expected_label = Calendar.strftime(prev_month, "%B %Y")
      assert has_element?(view, "#datepicker-month-label", expected_label)
    end

    test "can navigate to next month", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Click next month button
      view |> element("#datepicker-next-month") |> render_click()

      # Should now show the next month
      next_month = Date.utc_today() |> Date.end_of_month() |> Date.add(1)
      expected_label = Calendar.strftime(next_month, "%B %Y")
      assert has_element?(view, "#datepicker-month-label", expected_label)
    end
  end

  describe "Loading Button" do
    test "renders the button in idle state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Button should exist and show default text
      assert has_element?(view, "#loading-button")
      assert has_element?(view, "#loading-button", "Submit")

      # Should NOT show spinner in idle state
      refute has_element?(view, "#loading-button-spinner")
    end

    test "shows loading animation when clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Click the button to trigger loading
      view |> element("#loading-button") |> render_click()

      # Should now show spinner
      assert has_element?(view, "#loading-button-spinner")

      # Button text should change to loading state
      assert has_element?(view, "#loading-button", "Loading")
    end

    test "can be reset back to idle state", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Trigger loading
      view |> element("#loading-button") |> render_click()
      assert has_element?(view, "#loading-button-spinner")

      # Click the reset button to stop loading
      view |> element("#loading-button-reset") |> render_click()

      # Should be back to idle
      refute has_element?(view, "#loading-button-spinner")
      assert has_element?(view, "#loading-button", "Submit")
    end
  end

  describe "Product Search Bar" do
    test "renders the search bar section", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#product-search-bar-section")
      assert has_element?(view, "#product-search-bar")
    end

    test "renders the search bar with fuchsia background", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # The search bar container should have the fuchsia background style
      assert has_element?(view, "#product-search-bar[style*='background-color: #FF00FF']")
    end

    test "renders a search icon on the left", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#product-search-bar #product-search-bar-icon")
    end

    test "renders a filter icon on the right", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#product-search-bar #product-search-bar-filter-icon")
    end

    test "renders the text input for searching", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#product-search-bar-input")
    end

    test "shows autocomplete suggestions when typing", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Initially no dropdown visible
      refute has_element?(view, "#product-search-bar-dropdown")

      # Type a search query that matches grocery items
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Ban"})

      # Autocomplete dropdown should appear with matching items
      assert has_element?(view, "#product-search-bar-dropdown")
    end

    test "filters autocomplete suggestions based on input", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Type a partial grocery item name
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Avoc"})

      # Should show matching suggestion
      assert has_element?(view, "#product-search-bar-dropdown")
      assert has_element?(view, "#product-search-bar-suggestion-4", "Avocados")

      # Should NOT show non-matching items
      refute has_element?(view, "#product-search-bar-suggestion-1")
    end

    test "selecting a suggestion adds a pill to the search bar", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Type and select a grocery item
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()

      # A pill should appear with baby blue background
      assert has_element?(view, "#product-search-bar-pill-3")
      assert has_element?(view, "#product-search-bar-pill-3[style*='background-color: #89CFF0']")
    end

    test "pills show product name and a remove button", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Select a grocery item
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()

      # Pill should contain the item name
      assert has_element?(view, "#product-search-bar-pill-3", "Sourdough Bread")

      # Pill should have a remove button
      assert has_element?(view, "#product-search-bar-remove-3")
    end

    test "clicking remove on a pill removes it", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Select a grocery item
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()
      assert has_element?(view, "#product-search-bar-pill-3")

      # Remove the pill
      view |> element("#product-search-bar-remove-3") |> render_click()

      # Pill should be gone
      refute has_element?(view, "#product-search-bar-pill-3")
    end

    test "can select multiple products as pills", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Select first grocery item
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()

      # Select second grocery item
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Milk"})
      view |> element("#product-search-bar-suggestion-2") |> render_click()

      # Both pills should exist
      assert has_element?(view, "#product-search-bar-pill-3")
      assert has_element?(view, "#product-search-bar-pill-2")
    end

    test "already-selected products are not shown in autocomplete", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Select "Sourdough Bread"
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()

      # Search again — "Sourdough Bread" should not appear in suggestions
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      refute has_element?(view, "#product-search-bar-suggestion-3")
    end

    test "input clears after selecting a product", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Type and select
      view |> element("#product-search-bar-input") |> render_keyup(%{"value" => "Sour"})
      view |> element("#product-search-bar-suggestion-3") |> render_click()

      # Dropdown should close after selection
      refute has_element?(view, "#product-search-bar-dropdown")
    end

    test "pills container allows wrapping for multiple pills", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # The pills area should use flex-wrap so pills stack when the bar is full
      assert has_element?(view, "#product-search-bar-pills.flex-wrap")
    end
  end

  describe "Data Table" do
    test "renders the table with headers", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Table should exist
      assert has_element?(view, "#data-table")

      # Should have column headers
      assert has_element?(view, "#data-table th", "Name")
      assert has_element?(view, "#data-table th", "Role")
      assert has_element?(view, "#data-table th", "Status")
    end

    test "renders stub data rows", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Should have data rows (stub data)
      assert has_element?(view, "#data-table tbody tr")
    end

    test "displays status badges with appropriate styling", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # Status values should be rendered as badges
      assert has_element?(view, "#data-table .badge")
    end
  end

  describe "KPI Tile" do
    test "renders the kpi tile section", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#kpi-tile-section")
    end

    test "renders all 8 KPI tiles across two rows", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      for i <- 1..8 do
        assert has_element?(view, "#kpi-tile-#{i}")
      end
    end

    test "each tile displays a title and value", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#kpi-tile-1-title", "Active Projects")
      assert has_element?(view, "#kpi-tile-1-value", "8")
    end

    test "tiles with trends show arrow icons", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#kpi-tile-1-trend .text-success")
      assert has_element?(view, "#kpi-tile-2-trend .text-error")
    end

    test "tiles without trends have no trend element", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      refute has_element?(view, "#kpi-tile-4-trend")
    end

    test "every tile has a drop shadow", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#kpi-tile-1[style*='box-shadow']")
      assert has_element?(view, "#kpi-tile-5[style*='box-shadow']")
    end

    test "row 1 tiles can have custom border colors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      assert has_element?(view, "#kpi-tile-1[style*='border-color: #22c55e']")
    end

    test "row 2 tiles have no custom border color", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      refute has_element?(view, "#kpi-tile-5[style*='border-color']")
    end
  end
end
