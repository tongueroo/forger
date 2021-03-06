module Forger
  class Wait < Command
    desc "ami", "Wait until AMI available."
    long_desc Help.text("wait:ami")
    option :timeout, type: :numeric, default: 1800, desc: "Timeout in seconds."
    def ami(name)
      Waiter::Ami.new(options.merge(name: name)).wait
    end
  end
end
