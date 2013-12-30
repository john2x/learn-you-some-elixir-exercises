defmodule Hotload do
  """
  This is not used. Included for completeness.
  """
  def server(state) do
    receive do
      :update ->
        new_state = __MODULE__.upgrade(state)
        __MODULE__.server(new_state)
      _some_message ->
        # do something here
        server(state) # stay in the same version no matter what
    end
  end

  def upgrade(old_state) do
    # transform and return the state here
    old_state
  end
end
