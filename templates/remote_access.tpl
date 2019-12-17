{  
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RestrictRemoteAccess",
      "Effect":"Deny",
      "Action":"*",
      "Resource":"*",
      "Condition": {  
         "NotIpAddress":{  
            "aws:SourceIp":[  
               "159.142.0.0/16"
            ]
         }
      }
    }
  ] 
}