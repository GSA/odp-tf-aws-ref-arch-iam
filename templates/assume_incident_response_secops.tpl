{  
  "Version":"2012-10-17",
  "Statement":[  
     {  
        "Effect":"Allow",
        "Action":[  
           "sts:AssumeRole"
        ],
        "Resource":[  
           "arn:aws:iam::${cross_aws_account_id}:role/${project}-incident_response_secops"
        ]
     }
  ]
}