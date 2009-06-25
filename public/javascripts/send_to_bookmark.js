if(WScript.arguments.length == 0){
    WScript.quit();
}

var fs = WScript.createObject("Scripting.FileSystemObject");
var objIE = WScript.createObject("InternetExplorer.Application");

//var fileName = fs.getAbsolutePathName(WScript.arguments(0));

if(WScript.arguments(0).match(/^[\\][\\]/i)){
//    WScript.Echo (WScript.arguments(0) + " : " + fileName);
    fileName = encodeURIComponent(WScript.arguments(0));  //fileName);
    fileName = fileName.replace(/%5C/g,'/');
    objIE.navigate("http://localhost:3000/auth?redirect_add=/urllists/new?urllist[url]=file:" + fileName);
objIE.visible=true;

  }else{

    WScript.Echo ('ローカルPCのアドレスはブックマークできません');
    WScript.quit();
  }


//C:\windows\system32\wscript.exe "c:\open_current_add_by_ie.js" "%1"