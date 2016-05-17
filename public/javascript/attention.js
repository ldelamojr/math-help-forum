// alert("attention.js was loaded.");


intervalID = setInterval(function(){
	$("form").animate({opacity:"+=.3"},700)
	$("form").animate({opacity:"-=.3"},700)
});


$(".new_reply").on("focus", function() {
	clearInterval(intervalID);
	console.log("intervalID is " + intervalID);
	console.log("this is " + this);
});


// $("textarea").blur(doSetInterval());
// $("textarea").focus(function() {
// 	clearInterval(intervalID);
// });