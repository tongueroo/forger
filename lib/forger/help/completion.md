Example:

    forger completion

Prints words for TAB auto-completion.

Examples:

    forger completion
    forger completion hello
    forger completion hello name

To enable, TAB auto-completion add the following to your profile:

    eval $(forger completion_script)

Auto-completion example usage:

    forger [TAB]
    forger hello [TAB]
    forger hello name [TAB]
    forger hello name --[TAB]
