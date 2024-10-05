package main


empty(value) {
	count(value) == 0
}

no_violations {
	empty(deny)
}

test_blank_input {
	no_violations with input as {}
}

autoscaling_groups_names[key] = value {
    contains(input.resource_changes[i].address, "aws_autoscaling_group")
    key := input.resource_changes[i].address
    value := input.resource_changes[i].change.after.name
}

autoscaling_groups_non_compliant_prefix[key] {
    ssm_name:= autoscaling_groups_names[key]
    not startswith(ssm_name, "my_")
}

deny[msg] { 
    input.resource_changes[i].type == "aws_autoscaling_group" 
    input.resource_changes[i].address == "aws_autoscaling_group.my_asg"
    5 != input.resource_changes[i].change.after.max_size
    msg := sprintf("Max autscaling allowed is 5 : %v", [input.resource_changes[i].change.after.max_size])
}


deny[msg] {
    autoscaling_groups_non_compliant_prefix[_] != []  # if non_compliant_resources is empty, then the deny object is not even defined.
    msg := sprintf("Invalid SSM names (does not start with /team/<env> prefix) for the following resources: %v", [autoscaling_groups_names[_]])
}

test_no_violations_when_env_is_present_in_name {
	no_violations with input.resource_changes as [
	{
          "address": "module.main.aws_ssm_parameter.service_user_db_url",
          "change": {
            "actions": [
              "no-op"
            ],
            "after": {
              "id": "/team/prd-service/DB_URL",
              "name": "/team/prd-service/DB_URL",
              "tags": {
                "environment": "prd"
              },
              "value": "jdbc:mysql://team-prd-paymentsdb.czphpp7dqt72.us-east-1.rds.amazonaws.com:3306/prd",
              "version": 1
            }
          },
          "mode": "managed",
          "module_address": "module.main",
          "name": "service_user_db_url",
          "provider_name": "registry.terraform.io/hashicorp/aws",
          "type": "aws_ssm_parameter"
    }
    ]
}
