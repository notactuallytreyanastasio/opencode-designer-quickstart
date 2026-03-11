defmodule DesignSystemShowoffWeb.ShowcaseLiveTest do
  use DesignSystemShowoffWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "ShowcaseLive page structure" do
    test "renders the showcase page with all 3 component sections", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/showcase")

      # The page should have a title/header
      assert has_element?(view, "#showcase-page")

      # All 3 component sections should be present
      assert has_element?(view, "#datepicker-section")
      assert has_element?(view, "#loading-button-section")
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
end
