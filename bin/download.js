////BgetVersion 0.1.1
var url = WScript.Arguments(0),
  filename = WScript.Arguments(1),
  fso = WScript.CreateObject('Scripting.FileSystemObject'),
  request, stream;
if (fso.FileExists(filename)) {
  WScript.Echo('Already got ' + filename);
} else {
  request = WScript.CreateObject('MSXML2.ServerXMLHTTP');
  request.open('GET', url, false); // not async
  request.send();
  if (request.status === 200) { // OK
    WScript.Echo("Size: " + request.getResponseHeader("Content-Length") + " bytes");
    stream = WScript.CreateObject('ADODB.Stream');
    stream.Open();
    stream.Type = 1; // adTypeBinary
    stream.Write(request.responseBody);
    stream.Position = 0; // rewind
    stream.SaveToFile(filename, 1); // adSaveCreateNotExist
    stream.Close();
  } else {
    WScript.Echo('Failed');
    WScript.Quit(1);
  }
}
WScript.Quit(0);
