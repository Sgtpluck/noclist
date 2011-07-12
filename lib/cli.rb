require_relative "./api"

class CLI
  def self.run
    begin
      token = Auth.get_token
      STDOUT.print Users.get_list(token)
      exit 0
    rescue StandardError => e
      STDERR.puts e.message
      exit 1
    end
  end
end
