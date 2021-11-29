{
  "Version": "2012-10-17",
  "Id": "S3PolicyId1",
  "Statement": [
    {
      "Sid": "Rule0",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${principal_arn}"
      },
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]
    },
    {
      "Sid": "Allow_OAI",
      "Effect": "Allow",
      "Principal": {
                "AWS": [
                  "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${OAI_ID}"
                ]
            },
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket_name}",
        "arn:aws:s3:::${bucket_name}/*"
      ]    
    }
  ]
}