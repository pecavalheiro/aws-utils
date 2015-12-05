# aws-utils
Some Ruby scripts to help automating some actions in AWS services

### Requirements
`gem install aws-sdk`

### Commands:
- `flush-sg.rb` removes all inbound rules of a security group, rebuilding them from a defined schema. Helpful when you need to update your local IP in all rules.
