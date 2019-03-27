defmodule Inout.Web.Router do
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

  scope "/", Inout.Web do
    pipe_through :browser # Use the default browser stack

    get "/invoice", PageController, :index
    get "/", PageController, :index
    post "/in", PageController, :check_in

    get    "/login",  SessionController, :new
    post   "/login",  SessionController, :create
    delete "/logout", SessionController, :delete

    get "/events.json", EventController, :as_json
    resources "/events", EventController
    get "/contracts.json", ContractController, :as_json
    resources "/contracts", ContractController
    resources "/registrations", RegistrationController, only: [:new, :create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Inout do
  #   pipe_through :api
  # end
end
