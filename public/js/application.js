$(document).ready(function() {


});


// clean cruft from row or col headers.
// this gets rid of html whitespace and gov footnotes
function cleanStr(str) {
    ret = str;
    return ret.replace(/\n|<br>|\(\d\)$|\/\d$|%/g,"").replace(/&nbsp;/g," ");
}

// these were from http://www.somacon.com/p355.php
// modified to return copies
function trim(stringToTrim) {
    ret = stringToTrim;
    return ret.replace(/^\s+|\s+$/g,"");
}
function ltrim(stringToTrim) {
    ret = stringToTrim;
    return ret.replace(/^\s+/,"");
}
function rtrim(stringToTrim) {
    ret = stringToTrim;
    return ret.replace(/\s+$/,"");
}