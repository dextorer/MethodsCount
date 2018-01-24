require "spec_helper"

describe LibraryMethodsCount do

  describe "POST request" do
      it "enqueues the request" do
        get "/"

        expect(last_response.body).to eq("")
        expect(last_response.status).to eq 200
      end

    context "several todos" do
      before do
        @todos = ["hello", "world", "!"]
        $db = @todos
      end

      it "returns all the todos" do
        get "/"

        expect(last_response.body).to eq @todos.join("\n")
        expect(last_response.status).to eq 200
      end
    end
  end
end
