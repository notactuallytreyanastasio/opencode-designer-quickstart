defmodule DesignSystemShowoffWeb.PageController do
  use DesignSystemShowoffWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
