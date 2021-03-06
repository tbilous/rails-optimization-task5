require "rails_helper"

RSpec.shared_examples "an elevated privilege required request" do |path|
  context "when not logged-in" do
    it "does not grant acesss", proper_status: true do
      get path
      expect(response).to have_http_status(404)
    end

    it "raises Pundit::NotAuthorizedError internally" do
      expect { get path }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  context "when user is not trusted" do
    before { sign_in create(:user) }

    it "does not grant acesss", proper_status: true do
      get path
      expect(response).to have_http_status(404)
    end

    it "internally raise Pundit::NotAuthorized internally" do
      expect { get path }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end

RSpec.describe "Moderations", type: :request do
  let(:user) { create(:user, :trusted) }
  let(:article) { create(:article) }
  let(:comment) { create(:comment, commentable: article) }

  it_behaves_like "an elevated privilege required request", "/username/random-article/mod"
  it_behaves_like "an elevated privilege required request", "/username/comment/1/mod"

  context "when user is trusted" do
    before { sign_in user }

    it "grant access to comment moderation" do
      get comment.path + "/mod"
      expect(response).to have_http_status(200)
    end

    it "grant access to article moderation" do
      get article.path + "/mod"
      expect(response).to have_http_status(200)
    end

    it "grants access to /mod index" do
      get "/mod"
      expect(response).to have_http_status(200)
    end
    it "grants access to /mod index with articles" do
      create(:article, published: true)
      get "/mod"
      expect(response.body).to include("Experience Level Target")
    end
  end
end
