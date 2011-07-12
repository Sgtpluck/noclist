require "spec_helper"
require "cli"

describe CLI do
  describe "if an error in auth is returned" do
    it "should output a helpful error" do

      expect(Auth).to receive(:get_token).and_raise(StandardError.new "Error")
      expect(STDERR).to receive(:puts).with "Error"

      CLI.run
    end
  end

  describe "if an error in users is returned" do
    it "should output a helpful error" do
      expect(Auth).to receive(:get_token).and_return("12345")
      expect(Users).to receive(:get_list).and_raise(StandardError.new "Error")
      expect(STDERR).to receive(:puts).with "Error"

      CLI.run
    end
  end

  describe "auth token and list are both reurned" do
    it "puts the list in stdout" do
      list = [
        "1",
        "2",
        "3",
        "4",
        "5"
      ]
      expect(Auth).to receive(:get_token).and_return("12345")
      expect(Users).to receive(:get_list).and_return list

      expect(STDOUT).to receive(:puts).with list

      CLI.run
    end
  end
end
