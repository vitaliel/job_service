defmodule JobServiceWeb.Router do
  use JobServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", JobServiceWeb do
    pipe_through :api
    resources "/jobs", JobController, only: [:create]
    post "/jobs/bash", JobController, :bash
  end
end
