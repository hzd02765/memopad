// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function showItem(id){
	if ($('item' + id).innerHTML == '+') {
    	new Effect.SlideDown('desc' + id);
    	$('item' + id).innerHTML = '-';
  	} else {
    	new Effect.SlideUp('desc' + id);
    	$('item' + id).innerHTML = '+';
  	}
}