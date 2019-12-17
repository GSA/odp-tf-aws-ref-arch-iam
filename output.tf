output cloudwatch_delivery_role_id {
  value = "${aws_iam_role.cloudwatch_delivery.id}"
}

output cloudwatch_delivery_role_arn {
  value = "${aws_iam_role.cloudwatch_delivery.arn}"
}