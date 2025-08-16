# SWC-104: Unchecked Call Return Value

## Description
The return value of a message call is not checked, so execution will resume even if the called contract throws an exception.  
This means if the call fails accidentally or an attacker forces the call to fail, unexpected behavior may occur in the program logic.

## Remediation
- If low-level call methods are chosen, make sure to handle the possibility that the call will fail by checking the return value.
