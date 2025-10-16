RSpec.configure do |config|
  config.before(:each, openai: true) do
    allow(OpenAI::Client).to receive(:new).and_return(
      double(chat: {
        "choices" => [
          { "message" => { "content" => "テスト用AIコメント" } }
        ]
      })
    )
  end
end
