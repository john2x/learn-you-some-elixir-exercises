defmodule Records do
  defrecord Robot,
    name: nil,
    type: :industrial,
    hobbies: nil,
    details: []
  defrecord User,
    id: nil,
    name: nil,
    group: nil,
    age: nil

  def car_factory(corp_name), do: Robot.new(name: corp_name, hobbies: "building cars")

  def admin_panel(User[name: name, group: :admin]) do
    name <> " is allowed!"
  end
  def admin_panel(User[name: name]) do
    name <> " is not allowed!"
  end

  def adult_section(User[age: age] = user) when age >= 18 do
    # `age` needs to be deconstructed from the argument pattern
    # as `user.age` is a function call, and only a couple of BIFs
    # can be used in a guard clause
    :allowed
  end
  def adult_section(_), do: :forbidden

  def repairman(rob) do
    details = rob.details
    new_rob = rob.details(["Repaired by repairman" | details])
    { :repaired, new_rob }
  end
end

