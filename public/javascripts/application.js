// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  $(".autocomplete").autocomplete({
		'delay' : 500,
		'minLength' : 3,
	    'source': '/stations/' + escape($('#from').val())
	});
})