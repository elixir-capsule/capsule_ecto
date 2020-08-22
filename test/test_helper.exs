ExUnit.start()

Application.put_env(:capsule_ecto, :default_storage, Capsule.Ecto.Test.TestStorage)
