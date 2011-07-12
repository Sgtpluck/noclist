require "spec_helper"
require "api"

describe Auth do
  let(:auth) { Auth.new }

  describe "#initialization" do
    it "has a retry count of 0" do
      expect(auth.retries).to eq(0)
    end

    it "has an endpoint of 'http://0.0.0.0:8888/auth'" do
      expect(auth.endpoint).to eq("http://0.0.0.0:8888/auth")
    end
  end

  describe "#token" do
    let(:headers) do
      {
        "Badsec-Authentication-Token" => "020AFA3D-CD37-C0B3-2CE2-D1982FC9D3DC"
      }
    end
    let(:good_resp) { double { HTTP::Response }}
    let(:bad_resp) { double { HTTP::Response }}

    describe "works on the first go" do
      it 'returns a token' do
        expect(HTTP).to receive(:get)
          .with("http://0.0.0.0:8888/auth")
          .and_return good_resp

        expect(good_resp).to receive(:status).and_return(200)
        expect(good_resp).to receive(:headers).and_return headers
        expect(auth.token).to eq "020AFA3D-CD37-C0B3-2CE2-D1982FC9D3DC"
      end
    end

    describe "fails on the first go" do
      it 'returns a token' do

        expect(HTTP).to receive(:get)
        .with("http://0.0.0.0:8888/auth")
        .and_return bad_resp

        expect(bad_resp).to receive(:status).and_return(404)

        expect(HTTP).to receive(:get)
        .with("http://0.0.0.0:8888/auth")
        .and_return good_resp

        expect(good_resp).to receive(:status).and_return(200)
        expect(good_resp).to receive(:headers).and_return headers
        expect(auth.token).to eq "020AFA3D-CD37-C0B3-2CE2-D1982FC9D3DC"
        expect(auth.retries).to eq 1
      end
    end

    describe "fails three times" do
      it 'fails and returns an error' do

        expect(HTTP).to receive(:get)
        .exactly(3).times
        .with("http://0.0.0.0:8888/auth")
        .and_return bad_resp

        expect(bad_resp).to receive(:status).exactly(3).times.and_return(404)

        expect { auth.token }.to raise_error StandardError
      end
    end
  end
end
