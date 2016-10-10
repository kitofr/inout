defmodule Inout.Router do
  use Inout.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    #TODO Renable plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Inout do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    post "/in", PageController, :check_in

    resources "/events", EventController
    resources "/registrations", RegistrationController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Inout do
  #   pipe_through :api
  # end
end
