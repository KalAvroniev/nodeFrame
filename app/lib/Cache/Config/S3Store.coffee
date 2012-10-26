awssum = require('awssum')
amazon = awssum.load('amazon/amazon')
S3 = awssum.load('amazon/s3').S3

class S3Store
	module.exports = @
	
	constructor: () ->
		@s3 = new S3(
			'accessKeyId'     : app.config.aws.accessKeyId
			'secretAccessKey' : app.config.aws.secretAccessKey			
			'region'					: amazon.US_EAST_1
		)
		@s3.CheckBucket({ BucketName : app.config.aws.bucket }, (err, data) =>
			if err
				@s3.CreateBucket({ BucketName : app.config.aws.bucket }, (err, data) ->
					if err
						app.logger(err.Body.Error.Message, 'fatal')
				)
		)
		@retry = 3
		
	read: (bucket, file, modified = null, cb) ->
		options =
			BucketName			: bucket
			ObjectName			: file
			IfModifiedSince	: modified
			
		@s3.GetObject(options, (err, data) =>
			if err
				if @retry <= 0
					cb(err)
					
				@read(bucket, file, data, cb)
				@retry--
			else
				if data.StatusCode == 200
					cb(null, data.Body.toString())
				else	
					cb(null)	
		)
	
	write: (bucket, file, data, cb) ->
		options = 
			BucketName    : bucket
			ObjectName    : file
			ContentLength : Buffer.byteLength(data)
			Body          : data
			
		@s3.PutObject(options, (err, data) =>
			if err
				if @retry <= 0
					cb(err)
					
				@write(bucket, file, data, cb)
				@retry--
			else
				cb(null, data)
		)
			