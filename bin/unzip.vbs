Option Explicit
Dim args
Dim ZipFile
Dim ExtractTo
Dim fso
Dim objShell
Dim FilesInZip
Set args = Wscript.Arguments
ZipFile = args(0)
'The folder the contents should be extracted to.
ExtractTo = args(1)

'Extract the contants of the zip file.
set objShell = CreateObject("Shell.Application")
set FilesInZip=objShell.NameSpace(ZipFile).items
objShell.NameSpace(ExtractTo).CopyHere(FilesInZip)
Set fso = Nothing
Set objShell = Nothing