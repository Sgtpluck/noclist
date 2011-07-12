require "spec_helper"
require "api"

describe Users do
  let(:users) { Users.new("12345") }
  let(:checksum) do
    "c20acb14a3d3339b9e92daebb173e41379f9f2fad4aa6a6326a696bd90c67419"
  end

  describe "#initialization" do
    it "has a retry count of 0" do
      expect(users.retries).to eq(0)
    end

    it "has an endpoint of 'http://0.0.0.0:8888/users'" do
      expect(users.endpoint).to eq("http://0.0.0.0:8888/users")
    end

    it "creates a checksum out of the auth token" do
      expect(users.checksum).to eq checksum
    end
  end

  describe "#list" do
    let(:good_resp) { double { HTTP::Response } }
    let(:bad_resp) { double { HTTP::Response } }
    let(:http) { double { HTTP } }

    let(:body) do
      [
        "18207056982152612516",
        "7692335473348482352",
        "6944230214351225668",
        "3628386513825310392",
        "8189326092454270383",
        "12257150257418962584",
        "15245671842903013860"
      ].to_json
    end

    before do
      expect(HTTP).to receive(:headers).with(
        { "X-Request-Checksum": checksum }
      ).and_return http
    end

    describe "it succeeds on the first try" do
      it "returns a list of users" do
        expect(http).to receive(:get)
          .with("http://0.0.0.0:8888/users")
          .and_return good_resp

        expect(good_resp).to receive(:status).and_return(200)
        expect(good_resp).to receive(:body).and_return body

        expect(users.list).to eq body
      end
    end

    describe "it fails on the first try" do
      it "returns a list of users" do
        expect(http).to receive(:get)
          .once
          .with("http://0.0.0.0:8888/users")
          .and_return bad_resp

        expect(bad_resp).to receive(:status).and_return(404)

        expect(http).to receive(:get)
          .with("http://0.0.0.0:8888/users")
          .and_return good_resp

        expect(good_resp).to receive(:status).and_return(200)
        expect(good_resp).to receive(:body).and_return body

        expect(users.list).to eq body
        expect(users.retries).to eq 1
      end
    end

    describe "it fails three times" do
      it "returns an error" do
        expect(http).to receive(:get)
          .exactly(3).times
          .with("http://0.0.0.0:8888/users")
          .and_return bad_resp

          expect(bad_resp).to receive(:status).exactly(3).times.and_return(404)

          expect { users.list }.to raise_error StandardError
      end
    end
  end
end
