//<![CDATA[

	// global variables


	var array1 = new Array();
	var array2 = new Array();

	function json2array(json_data){
		array1 = eval(json_data);
		
	}


function checkNull(obj){
  if(obj.value==''){
    alert('アドレスが空です。アドレスを入力してください！');
    obj.focus();
    return false;
  }
  if(obj.value.match(/^[\\][\\]|^[http]/i)){
  	return true;
  }else{
    alert('間違ったアドレスです。先頭が "\\\\"or"http"で始まるアドレスを入力してください！');
    obj.focus();
    return false;
  }

  return true;
}


//]]>