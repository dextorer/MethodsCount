module QueueService
  extend self

  def enqeue(message_hash)
    sqs = Aws::SQS::Client.new(region: 'eu-west-1')
    sqs.send_message({
                       queue_url: ENV['SQS_QUEUE_URL'],
                       message_body: message_hash.to_json
    })
  end

end
