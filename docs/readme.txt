Table of Contents
1.	Introduction
2.	Features
3.	Running Bget
4.	Switches
	a.	GET
	b.	PASTEBIN
	c.	REMOVE
	d.	UPDATE
	e.	INFO
	f.	LIST
	g.	UPGRADE
	h.	HELP
	i. 	OPENSCRIPTS
	j. 	SEARCH
	k.	NEWSCRIPTS
	l.	SET
	m.	QUERY
	n.	NOBANNER
	o.	REFRESH
5.	Methods
	a.	Jscript -JS
	b.	Visual Basic Script -VBS
	c.	Powershell -PS
	d.	BITSAdmin -BITS
	e.	cURL
6.	Troubleshooting
7.  Contact
8.  Thanks

INTRODUCTION
Bget is a batch-file command-line tool for handling Windows scripts. It is built to be a companion to those who write, use and maintain Windows scripts. It helps those who use scripts easily download, update and remove scripts. It's built for scripters, by scripters.
Bget was conceived in 2016, but this reincarnation of Bget was made in 2018.

Features
1.	Download scripts from the Bget server: These scripts are vetted and sorted by us. We've gone about curating some of the most interesting scripts we could find that we think would be interesting and useful to you as well.
2.	Download scripts from Pastebin: Pastebin has long been the coder's friend, and so we added the ability to fetch scripts from Pastebin. These scripts are not pre-vetted however, but they offer the ability for fast code downloading without waiting for us to vet them.
3.	Update scripts: Rather than manually re-download the latest version of every script, Bget handles that for you, getting the latest version of any script you've downloaded.
4.	Easily remove scripts: Don't like a script you downloaded? Easily remove it with Bget. One command and it's buh-bye script.
5.	View script info: This allows you to see basic information about a script such as its name, author and description, allowing you to make an informed decision before downloading.
6.	Bget also allows you to list all scripts on the server and list downloaded scripts on the local computer.
7.	Upgrade feature: Bget also updates itself so you always stay up-to-date.
8.	Multiple download methods: Bget has many ways to get a script. These are: Jscript, VBScript, Powershell, BITSAdmin and cURL.


Running Bget
Captain Obvious: Bget is a command-line tool, so it needs to be run from the command line. A typical Bget command looks like this: 
Bget [-switch] [-method] [ARGUMENT]

Here's an example:
Scenario: You want to fetch a script named test from the server. The easiest way to do this would be:
BGET -get -usecURL test

Switches

[A] -Get:
This is the script fetching function.
Usage:
BGET -get -usemethod script
Supported methods: JS, VBS, PS, cURL, BITS
Example:
BGET -get -usevbs test
The above will download the script named "test" from the Bget server using the VBS download function.
To get more than one script at once, use:
BGET -get -usemethod "scripts"
Example:
BGET -get -usecURL "test tetris bigtext"
You can also get all the scripts on the bget server.
Usage:
BGET -get -usemethod -all
Example:
BGET -get -usejs -all
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[B] -Pastebin:
This fetches a pastebin raw and saves it as a .bat script.
Usage:
BGET -pastebin -usemethod PASTECODE LOCAL_FILENAME
Supported methods: JS, VBS, PS, cURL.
BITSADMIN (BITS method) is not compatible with the -pastebin switch.
Example:
BGET -pastebin -usecURL 1wsBxRs4 script.bat
The paste code is the unique element of a Pastebin URL.
i.e., A Pastebin script located at https://pastebin.com/YkEtQYFR would have YkEtQYFR as its paste code. If you get the paste code wrong, you'll get a Pastebin error webpage as the output file instead of your intended script. Also, the Pastebin scripts have not been vetted by us so be sure to inspect all scripts fetched from Pastebin.
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[C] -Remove:
Removes a downloaded script
Usage:
BGET -remove script
Example:
BGET -remove test
To remove more than one script at once, 
Example:
BGET -remove "test tetris bigtext"
You can also remove all scripts at once.
Example:
BGET -remove -all -y
To remove all pastebin scripts:
BGET -remove -pastebin
The remove function can also be used to clear logs.
Example:
BGET -remove -logs

[D] -Update:
Updates the specified script.
Usage:
BGET -update -usemethod script
Supported methods: JS, VBS, PS, cURL, BITS
Example:
BGET -update -usejs test
To update more than one script at once,
BGET -update -usemethod "script1 script2 script3 scriptn"
Example:
BGET -update -usecURL "test tetris bigtext"
You can also update all your scripts at once.
Usage:
BGET -update -usemethod -all
Example:
BGET -update -usejs -all
You can force an upgrade as well.
Usage:
BGET -update -usemethod [-all/SCRIPTNAME] -force
Example:
BGET -update -usecURL -all -force
BGET -update -usejs test -force
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[E] -Info:
Retrieves basic info about a script.
Usage:
BGET -info -usemethod script
Supported methods: JS, VBS, PS, cURL, BITS
Example:
BGET -info -usevbs test
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[F] -List:
Lists either local scripts or scripts on the server.
Usage:
To list local sctipts:
BGET -list -local
To list scripts on the server:
BGET -list -server -usemethod
Example:
BGET -list -server -usejs
Supported methods: JS, VBS, PS, cURL, BITS
You can also view the list with less formatting, so you can see the full descriptions.
Usage:
BGET -list -server -usemethod -full
Example:
BGET -list -server -usejs -full
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.
It is possible to sort the script list got from the server by use of the -only and -sortby switches.
	[i] -only: lists scripts that match a certain criteria, e.g. category, author, date, and name.
		For example, you can list only scripts that have the field author as "Jahwi" by typing:
		BGET -list -server -only author jahwi
		Additionally, you can use the -full switch to display slightly unformated output.
		BGET -list -server -only jahwi -full
	[ii] -sortby: sorts output by different criteria e.g. category, author, date, and name.
		For example, to sort the script list by category:
		BGET -list -server -sortby category
		Like with the -only switch, the -full switch can be used as well to display slightly unformated output.
		BGET -list -server -sortby category -full

[G] -Upgrade:
Updates bget to the latest version
Usage:
BGET -upgrade -usemethod
Example:
BGET -upgrade -usevbs
Supported methods: JS, VBS, PS, cURL, BITS
You can also force Bget to get the latest version, regardless of that currently installed.
Usage:
BGET -upgrade -usemethod -force
Example:
BGET -upgrade -usecURL -force
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[H] -HELP:
Prints the help text.
-help -doc opens this readme.
you can also use BGET -help [command] to get help info related to a bget command.
e.g. BGET -help -get

[I] -OPENSCRIPTS
Opens the scripts folder.

[J] -SEARCH
Search for scripts on the Bget server.
Usage:
BGET -search -usemethod "string"
Example:
BGET -search -usejs "Jahwi"

[K] -NEWSCRIPTS
[K] -NEWSCRIPTS
Shows you new scripts we've added.
Usage:
BGET -newscripts -usemethod
Example:
BGET -newscripts -usejs
For Bget versions 0.2.0 and later, you no longer need to specify a download method.
However, the default download method has been set to `JS` and this can be changed using the SET switch.

[L] -SET
Changes global variables such as the default downlaod method.
Usage scenario [1]: changing the default download method.
BGET -set ddm {method}
Example:
BGET -set ddm vbs
Usage scenario [2]: toggle auto-delete logs (toggles deletion of temp files)
BGET -set adl {option}
Example:
BGET -set adl yes
Usage scenario [3]: Change the default scripts location.
BGET -set scl "path"
Example:
BGET -set scl "C:\scripts"
Usage scrnario [4]: Toggling the refresh script list (re-downloading of the script list on every get operation)
BGET -set rsl no

[M] -QUERY
Displays the values of select global variables.
Usage:
BGET -QUERY {variable_name}
Example:
BGET -QUERY defmethod
You can also query all the configurable global variables.
Example: BGET -QUERY -all

[N] -NOBANNER
Supresses the banner that Bget displays on every run.
Usage:
BGET -NOBANNER -get test

[O] -REFRESH
Fetches the latest version of the script list, and stores it locally.

Methods
Bget's 'methods' are the various ways through which Bget interacts with servers. There are currently 5 methods:

The JS method: It uses a JS download script.
The VBS method: Uses a download script written in VBS.
The PS method: uses Powershell to download resources.
The BITS method: Uses bitsadmin to download resources. It is not compatible with the Pastebin switch.
The cURL method: Uses cURL to download resources.
Usage:

BGET [-switch] [-method] [-script]

Where the methods are: -usejs, -usevbs, -useps, -usebits, -usecURL. It should be noted that the BITS method does not work
with scripts located on external repositories.

Examples:

BGET -get -usejs test
BGET -update -usevbs test
BGET -pastebin -useps 1wsBxRs4
BGET -list -server -usebits
BGET -upgrade -usecURL
BGET -info -usejs test

TROUBLESHOOTING

[1] VBS/JS download methods fail: This is typically caused by antivirus software.
	Remedies:	[a] Whitelist the Bget path or
				[b] Use the BITS/PS methods
[2] BITS download method fails: BITS method is slow and does not download scripts from external repositories.
	Remedies:	[a] Use other methods.
[3] External-File-No-Hash-Available
	These occur because the script is located in an external repository. There is no remedy for now.
[4] Nil in the "Last Modified" field
	These occur because the script is located in an external repository. There is no remedy for now.
				

Contact
If you're having an issue with bget, would like to submit a script or just want to chat (jk, we're boring people), contact us at batchget [at] gmail [dot com]

Thanks
I'd like to say thanks to the following:
b00st3d
Icarus Lives
Freebooter
Setlucas
Lowsun

I'd also like to credit the creators of cURL.