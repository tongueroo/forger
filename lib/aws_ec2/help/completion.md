Example:

    aws-ec2 completion

Prints words for TAB auto-completion.

Examples:

    aws-ec2 completion
    aws-ec2 completion hello
    aws-ec2 completion hello name

To enable, TAB auto-completion add the following to your profile:

    eval $(aws-ec2 completion_script)

Auto-completion example usage:

    aws-ec2 [TAB]
    aws-ec2 hello [TAB]
    aws-ec2 hello name [TAB]
    aws-ec2 hello name --[TAB]
