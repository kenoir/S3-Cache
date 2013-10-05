require 'aws-sdk'

class S3Cache

  def initialize(id = S3_BUCKET)
    @s3_bucket = AWS::S3.new(
      :access_key_id => AWS_ACCESS_KEY,
      :secret_access_key => AWS_SECRET_KEY
    ).buckets[id]
  end

  def get(object_id)
    @s3_bucket.objects[object_id].read
  end

  def put(object_id, data)
    @s3_bucket.objects[object_id].write(data)
  end

end


