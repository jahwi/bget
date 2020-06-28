# Bget

## CMD:
![Bget screenshot](https://github.com/jahwi/bget-list/blob/master/images/cmdimg.PNG)

## Powershell:
![Bget powershell screenshot](https://github.com/jahwi/bget-list/blob/master/images/psimg.PNG)


## Table of Contents
1. [Introduction](https://github.com/jahwi/bget/blob/master/README.md#introduction)
2. [Features](https://github.com/jahwi/bget/blob/master/README.md#features)
3. [Running Bget](https://github.com/jahwi/bget/blob/master/README.md#running-bget)
4. [Switches](https://github.com/jahwi/bget/blob/master/README.md#switches)
5. [Methods](https://github.com/jahwi/bget/blob/master/README.md#methods)
	- Jscript -JS
	- Visual Basic Script -VBS
	- Powershell -PS
	- BITSAdmin -BITS
	- CURL
6. [Contact](https://github.com/jahwi/bget/blob/master/README.md#contact)

## INTRODUCTION
Bget is a batch-file command-line tool for handling Windows scripts. It is built to help script writers and users alike easily download, update and remove scripts. It’s built for scripters, by scripters.

## Features
1. Download scripts from the Bget server: These scripts are vetted and sorted by us. We’ve gone about curating some of the most interesting scripts we could find that we think would be interesting and useful to you as well. Choose from over 100 scripts currently indexed by Bget.
2. Download scripts from Pastebin: Pastebin has long been the coder’s friend, and so we added the ability to fetch scripts from Pastebin. These scripts are not pre-vetted however, but they offer the ability for fast code downloading without waiting for us to vet them.
3. Update scripts: Rather than manually re-download the latest version of every script, Bget handles that for you, getting the latest version of any script you’ve downloaded.
4. Easily remove scripts: Don’t like a script you downloaded? Easily remove it with Bget. One command and it’s buh-bye script.
5. View script info: This allows you to see basic information about a script such as its name, author and description, allowing you to make an informed decision before downloading.
6. Bget also allows you to list all scripts on the server and list downloaded scripts on the local computer.
7. Upgrade feature: Bget also updates itself so you always stay up-to-date.
8. Multiple download methods: Bget has many ways to get a script. These are: Jscript, VBScript, Powershell, BITSAdmin and CURL.

## Running Bget
Captain Obvious: Bget is a command-line tool, so it needs to be run from the CLI. A typical Bget command looks like this:

`Bget [-switch] [-method] [ARGUMENT]`

Here’s an example:

Fetching a script named `test` from the server.  The easiest way to do this would be:

`BGET -get -usecurl test`

You should open a Command Prompt window in Bget's path before running any of the commands. Optionally, you could also add Bget's path as an environment variable.

## Switches

Run `BGET -help -doc` to get a comprehensive list of Bget's switches.


## Methods
Bget’s  ‘methods’ are the various ways through which Bget interacts with servers.
There are currently 5 methods:
1.	The JS method: It uses a JS download script.
2.	The VBS method: Uses a download script written in VBS.
3.	The PS method: uses Powershell to download resources.
4.	The BITS method: Uses bitsadmin to download resources. It is not compatible with the Pastebin switch.
5.	The CURL method: Uses curl to download resources.

Usage:

`BGET [-switch] [-method] [script]`

Where the methods are: -usejs, -usevbs, -useps, -usebits,  -usecurl.

Examples:

1. `BGET -get -usejs test`
2. `BGET -update -usevbs test`
3. `BGET -pastebin -useps 1wsBxRs4`
4. `BGET -list -server -usebits`
5. `BGET -upgrade -usecurl`
6. `BGET -info -usejs test`

## Contact
If you're having an issue with bget, would like to submit a script, contact us at batchget [at] gmail [dot com]


