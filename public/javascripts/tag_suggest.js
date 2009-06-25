var KEY_BS = 8;
var KEY_TAB = 9;
var KEY_ENTER = 13;
var KEY_SHIFT = 16;
var KEY_ESC = 27;
var KEY_LEFT = 37;
var KEY_UP = 38;
var KEY_RIGHT = 39;
var KEY_DOWN = 40;
var KEY_LEFT_BRACKET = 219;
var KEY_RIGHT_BRACKET = 221;
var KEY_LEFT_BRACKET_OPERA = 91; /* for Opera8 */
var KEY_RIGHT_BRACKET_OPERA = 93; /* for Opera8 */

var candidatesListDiv;
var userTagsListDiv;
var otherTagsListDiv;

var commentInput;

var addedTags = new Array();
var candidates = new Array();
var suggesting = false;
var selectedIndex = 0;
var wordStartPos = 0;

var tags;
var otherTags;

var isOpera8 = window.opera && window.opera.version ? parseInt(window.opera.version()) > 7 ? true : false : false;
var isMSIEorGecko = false;


if (navigator.userAgent.indexOf("Opera") == -1 &&
	navigator.userAgent.indexOf("Safari") == -1) {
	
	if(navigator.userAgent.indexOf("MSIE") != -1 ||
	   navigator.userAgent.indexOf("Gecko") != -1 )
		isMSIEorGecko = true;
}

function moveCaret(target, index) {
	if (! isMSIEorGecko) return null;
	if (document.all) {
		var txt_rng = target.createTextRange();
		txt_rng.collapse();
		txt_rng.move("character", index);
		txt_rng.select();
	} else if(document.getElementById) {
		target.setSelectionRange(index, index);
	}
}
function getCaretPos(target) {
	if (isMSIEorGecko) {
		if (document.all) {
			var sel_rng = document.selection.createRange();
			var txt_rng = target.createTextRange();
			txt_rng.setEndPoint("EndToStart", sel_rng);
			return txt_rng.text.length;
		} else if(document.getElementById) {
			return target.selectionStart;
		} else {
			return 0;
		}
	} else if (isOpera8) {
		if ( commentInput.value.match(/^((\[[^\[\]]+?\]){0,9}\[[^\[\]]*)(\[[^\[\]]+?\]){0,9}/) ) {
			return RegExp.$1.length;
		} else {
			return 0;
		}
	} else {
		return null;
	}
}
function getNormalizedTags(target) {
	var newTags = new Array();
	for(var i=0; i<target.length; i++) {
		var t = target[i];
		if (t.length>0) {
			t = t.replace(/&#39;/g, "'");
			t = t.replace(/&amp;/g, "&");
			t = t.replace(/&lt;/g, "<");
			t = t.replace(/&gt;/g, ">");
			t = t.replace(/&quot;/g, "\"");
			newTags.push(t);
		}
	}
	return newTags;
}
function getLowerTags(target) {
	var newTags = new Array();
	for(var i=0; i<target.length; i++) {
		var t = target[i];
		if (t.length>0) {
			t = t.toLowerCase();
			newTags.push(t);
		}
	}
	return newTags;
}

function getAbsoluteLeft(element) {
    var left = 0;
    for (var e = element; e; e = e.offsetParent) {
        left += e["offsetLeft"];
    }
	return left;
}
function getAbsoluteTop(element) {
	var top = 0;
	for (var e = element; e; e = e.offsetParent) {
		top += e["offsetTop"];
	}
	return top;
}
function updateAddedTags() {
	commentInput.value.match(/((\[[^\[\]]+?\])*)/);
	var buftags = RegExp.$1.match(/\[([^\[\]]+?)\]/g);
	if (! buftags) {
		if (addedTags.length>0) {
			addedTags = new Array();
			return true;
		}
		return false;
	}
	newTags = new Array();
	for (var i=0; i<buftags.length; i++) {
		newTags.push(buftags[i].slice(1, -1));
	}
	if (newTags.length != addedTags.length) {
		addedTags = newTags;
		return true;
	}
	return false;
}

function isAdded(tagName) {
	for (var i=0; i<addedTags.length; i++) {
		if (addedTags[i] == tagName)
			return true;
	}
	return false;
}
function addTag(tagName) {
	if (navigator.userAgent.indexOf("Safari") == -1) {
		commentInput.value = commentInput.value.replace(
			/^((\[[^\[\]]+?\])*)/,
			function(t){
				return t+"["+tagName+"]";
			});
	} else { // for safari
		commentInput.value.match(/(\[.+\])(.*)/);
		if (RegExp.$1)
			commentInput.value = RegExp.$1+"["+tagName+"]"+RegExp.$2;
		else {
			commentInput.value = "["+tagName+"]"+commentInput.value;
		}
	}
}
function removeTag(tagName) {
	commentInput.value = commentInput.value.replace("["+tagName+"]", "");
}

//
// 補完一覧
//
function createCandidateWord(tagName, selected) {
	var tagSpan = document.createElement("span");
	with(tagSpan.style) {
		padding = "1 5 1 5";
		fontSize = "10pt";
	}
	if (selected) {
		tagSpan.style.backgroundColor = "#6666FF";
		tagSpan.style.color = "white";
	}
	tagSpan.appendChild(document.createTextNode(tagName));
	return tagSpan;
}
function removeCandidatesList() {
	var oldCandidatesListDiv = candidatesListDiv.firstChild;
	if (oldCandidatesListDiv)
		oldCandidatesListDiv.parentNode.removeChild(oldCandidatesListDiv);
}
function updateCandidatesList() {
	if (!suggesting || candidates.length==0)
		removeCandidatesList();
	else {
		var div = document.createElement("div");
		with(div.style) {
			width = "100%";
			marginTop = "3";
			backgroundColor = "white";
			fontFamily = "sans-serif";
		}
		for (var i=0; i<candidates.length; i++) {
			var selected = (i==selectedIndex);
			div.appendChild(createCandidateWord(candidates[i], selected));
			div.appendChild(document.createTextNode(" "));
		}
		var tab = document.createElement("div");
		with(tab.style) {
			width = document.getElementById("comment").offsetWidth;
			padding = "1 0 1 5";
			marginTop = "3";
			fontSize = "8pt";
			borderTop = "1px solid #999999";
			color = "#999999";
		}
		
		tab.appendChild(document.createTextNode("決定[Enter]"));
		if (candidates.length>=2) {
			tab.appendChild(document.createTextNode(" / 選択[Tab][←][→]"));
		}
		div.appendChild(tab);
		
		removeCandidatesList();
		candidatesListDiv.appendChild(div);
	}
}

//
// ユーザーのタグ一覧
//
function selectTag(tag) {
	tag.style.backgroundColor = "#dddddd";
	tag.style.color = "black";
	tag.onmouseover = function() {};
	tag.onmouseout = function() {};
	tag.onmousedown = function() {
		removeTag(this.firstChild.nodeValue);
		updateAllTagsLists();
	};
	if (isMSIEorGecko){
		tag.onmouseup = function() {
			var pos = commentInput.value.match(/((\[[^\[\]]+?\])*)/)[0].length;
			moveCaret(commentInput, pos);
			commentInput.focus();
		};
	}
}
function unselectTag(tag) {
	tag.style.backgroundColor = "white";
	tag.style.color = "#777777";
	tag.onmouseover = function() {
		this.style.backgroundColor = "#eeeeee";
	};
	tag.onmouseout = function() {
		this.style.backgroundColor = "white";
	};
	tag.onmousedown = function() {
		addTag(this.firstChild.nodeValue);
		updateAllTagsLists();
	};
	if (isMSIEorGecko){
		tag.onmouseup = function() {
			var pos = commentInput.value.match(/((\[[^\[\]]+?\])*)/)[0].length;
			moveCaret(commentInput, pos);
			commentInput.focus();
		};
	}
}
function createTagSpan(tagName, tagid) {
	var tagSpan = document.createElement("span");
	tagSpan.id = tagid;
	with(tagSpan.style){
		padding = "1 4 1 4";
		fontSize = "10pt";
		fontFamily = "sans-serif";
		cursor = "pointer";
	}
	tagSpan.appendChild(document.createTextNode(tagName));
	return tagSpan;
}
function appendUserTagsList() {
	if (tags.length==0) return;
	var div = document.createElement("div");
	with(div.style) {
		width = "100%";
		lineHeight = "140%";
		marginTop = "10";
	}
	
	var titleDiv = document.createElement("div");
	titleDiv.style.fontSize = "10pt";
//	titleDiv.style.fontWeight = "bold";
	titleDiv.appendChild(document.createTextNode("自分のタグ一覧"));
	div.appendChild(titleDiv);
	
	for (var i=0; i<tags.length; i++) {
		div.appendChild(createTagSpan(tags[i], "tag"+i));
		div.appendChild(document.createTextNode(" "));
	}
	
	userTagsListDiv.appendChild(div);
	
	// 選択・非選択
	for (var i=0; i<tags.length; i++) {
		if (isAdded(tags[i])) {
			selectTag(document.getElementById("tag"+i));
		} else {
			unselectTag(document.getElementById("tag"+i));
		}
	}
}

//
// 他人のタグ一覧
//
function appendOtherTagsList() {
	if (otherTags.length==0) return;
	var div = document.createElement("div");
	with(div.style) {
		width = "100%";
		lineHeight = "130%";
		marginTop = "10";
	}
	
	var titleDiv = document.createElement("div");
	titleDiv.style.fontSize = "10pt";
//	titleDiv.style.fontWeight = "bold";
	titleDiv.appendChild(document.createTextNode("みんなのタグ"));
	div.appendChild(titleDiv);
	
	for (var i=0; i<otherTags.length; i++) {
		div.appendChild(createTagSpan(otherTags[i], "otherTag"+i));
		div.appendChild(document.createTextNode(" "));
	}
	otherTagsListDiv.appendChild(div);
	
	// 選択・非選択
	for (var i=0; i<otherTags.length; i++) {
		if (isAdded(otherTags[i])) {
			selectTag(document.getElementById("otherTag"+i));
		} else {
			unselectTag(document.getElementById("otherTag"+i));
		}
	}
}


//
// ハンドラ
//
function preventDefaultEvent(e) {
	// イベントキャンセル(for Gecko)
	if (e.preventDefault) {
		e.preventDefault();
		e.stopPropagation();
	} else {
		e.returnValue = false;
	}
}
function onKeyPressHandler(e) {
	e = (e) ? e : window.event;
	var ascii = (e.charCode) ? e.charCode : ((e.which) ? e.which : e.keyCode);
	switch (ascii) {
	case 13: // Enter
		if (! suggesting) break;
		if (candidates.length==0) {
			suggesting = false;
			selectedIndex = 0;
			break;
		}
		suggesting = false;
		
		// 文字挿入
		var word = candidates[selectedIndex];
		var currentPos = getCaretPos(commentInput);
		var str = commentInput.value;
		var pre = str.substring(0, wordStartPos);
		var suf = str.substring(currentPos);
		commentInput.value = pre+word+"]"+suf;
		
		// 描画更新
		updateCandidatesList();
		updateAllTagsLists();
		
		// フォーカス
		var pos = wordStartPos+word.length+1;
		moveCaret(commentInput, pos);
		commentInput.focus();
		if (isOpera8) {
			var txt_rng = commentInput.createTextRange();
			setTimeout('commentInput.focus()', 10);
			setTimeout('commentInput.select()', 11);
		}
		preventDefaultEvent(e);
		break;
	}
	
	switch (e.keyCode) {
	case KEY_TAB:
	case KEY_UP:
	case KEY_DOWN:
	case KEY_LEFT:
	case KEY_RIGHT:
		if (suggesting) {
			if (isOpera8) {
				if(e.keyCode==KEY_TAB || e.which==0) {
					var txt_rng = commentInput.createTextRange();
					setTimeout('commentInput.focus()', 10);
					setTimeout('commentInput.select()', 11);
				}
			}
			if (!isOpera8 && e.preventDefault)
				preventDefaultEvent(e); // for Gecko
		}
		break;
	}
}
function onKeyDownHandler(e) {
	e = (e) ? e : window.event;
	switch (e.keyCode) {
	case KEY_TAB:
	case KEY_UP:
	case KEY_DOWN:
	case KEY_LEFT:
	case KEY_RIGHT:
		if (! suggesting) break;
		if (candidates.length == 0) {
			if (e.keyCode==KEY_RIGHT || e.keyCode==KEY_LEFT) {
				suggesting = false;
				selectedIndex = 0;
			}
			break;
		}
		
		// 候補選択
		if ((e.keyCode==KEY_TAB && e.shiftKey == true) ||
				e.keyCode==KEY_UP ||
				e.keyCode==KEY_LEFT) {
			if (selectedIndex <= 0)
				selectedIndex = candidates.length-1;
			else
				selectedIndex -= 1;
		} else {
			if (selectedIndex >= candidates.length-1)
				selectedIndex = 0;
			else
				selectedIndex += 1;
		}
		updateCandidatesList();
		
		preventDefaultEvent(e); // for IE
		break;
		
	case KEY_BS:
		if (! suggesting) break;
		// [を消したら補完終了
		var currentPos = getCaretPos(commentInput);
		if (wordStartPos == currentPos) {
			suggesting = false;
		}
		selectedIndex = 0;
		break;
	case KEY_ENTER: // onpressで処理
		break;
	case KEY_SHIFT:
		break;
	default:
		selectedIndex = 0;
	}
}
function onKeyUpHandler(e) {
	e = (e) ? e : window.event;
	candidates = new Array();
	var currentPos = getCaretPos(commentInput);
	
	switch (e.keyCode) {
	case KEY_LEFT_BRACKET:
	case KEY_LEFT_BRACKET_OPERA:
		// 補完開始
		wordStartPos = currentPos;
		suggesting = true;
		break;
	case KEY_RIGHT_BRACKET:
	case KEY_RIGHT_BRACKET_OPERA:
		// 補完終了
		suggesting = false;
		break;
	default:
		if (! suggesting) break;
		// 候補を絞り込み
		if (currentPos<=wordStartPos) break;
		var unfinishedWord = commentInput.value.substring(
			wordStartPos, currentPos
			).toLowerCase();
		for (var i=0; i<tags.length; i++) {
			if (tags_lower[i].indexOf(unfinishedWord)==0) {
				if (! isAdded(tags[i])) {
					candidates.push(tags[i]);
				}
			}
		}
	}
	
	switch (e.keyCode) {
	case KEY_TAB:
	case KEY_UP:
	case KEY_DOWN:
	case KEY_LEFT:
	case KEY_RIGHT:
	case KEY_ENTER:
	case KEY_SHIFT:
		break;
	default:
		updateCandidatesList();
		updateAllTagsLists();
	}
}
function updateAllTagsLists() {
	if (updateAddedTags()) {
		for (var i=0; i<tags.length; i++) {
			if (isAdded(tags[i])) {
				selectTag(document.getElementById("tag"+i));
			} else {
				unselectTag(document.getElementById("tag"+i));
			}
		}
		for (var i=0; i<otherTags.length; i++) {
			if (isAdded(otherTags[i])) {
				selectTag(document.getElementById("otherTag"+i));
			} else {
				unselectTag(document.getElementById("otherTag"+i));
			}
		}
	}
}

//
// 初期化
//
function compare(a,b) {
	if (a.toLowerCase() > b.toLowerCase())
		return 1;
	else
		return -1;
}
function tag_suggest_init(x,y,form_name) {
 tags=x;
 otherTags=y;


	commentInput = document.getElementById("comment");
	candidatesListDiv = document.getElementById("candidates_list");
	candidatesListDiv.style.height = "40px";
	userTagsListDiv = document.getElementById("tags_list");
	otherTagsListDiv = document.getElementById("othertags_list");
	
	updateAddedTags();
	
	if (tags) {
		tags = getNormalizedTags(tags);
		// tags = tags.sort(compare);
		tags_lower = getLowerTags(tags);
		appendUserTagsList();
	}


	if (otherTags) {
		otherTags = getNormalizedTags(otherTags);
		appendOtherTagsList();
	}

	commentInput.setAttribute( "autocomplete", "off" );
	commentInput.onkeydown = onKeyDownHandler;
	commentInput.onkeypress = onKeyPressHandler;
	commentInput.onkeyup = onKeyUpHandler;
	
	//var editForm = document.getElementById("edit_form");
        var editForm = document.getElementById(form_name);

	editForm.onsubmit = function() {
		if(document.getElementById('urllist_title').value == ''){
    			alert('タイトルを入力してください！');
			editForm.focus();
		    	return false;
		}
                else{

			if (candidatesListDiv.firstChild)
				return false;
			disableSubmit(editForm);
		}
	}

}

Event.observe(window, 'load', function () {
    var go_bm = $("go_bm");
    if(!go_bm) return;
    go_bm.checked =  document.cookie.indexOf("go_bm=1") > 0 ? true : false;
    Event.observe(go_bm, 'click', function () {
      var g = go_bm.checked ? 1 : 0;
      var d = new Date();
      d.setTime(d.getTime()+2592000000);//30days
      document.cookie = "go_bm=" + g + ";expires=" + d.toGMTString();
      },false);
    }, false);

function disableSubmit(form) {
  var elements = form.elements;
  for (var i = 0; i < elements.length; i++) {
    if (elements[i].type == 'submit') {
      elements[i].disabled = true;
    }
  }
}
 