$(document).ready(function(){});
//When you click on a link with class of poplight and the href starts with a # 
function call_pop(str,empid,detid) 
{
	var datastring='eid='+empid+'&did='+detid;
//	$.ajax({
//			type:"POST",
//			url:'/users/index',
//			data:null,
//			success:function(result){
//			$('#popup1').html(result);
//			}
//		});
    $('#popup1').load(str+"?id="+empid);
	$('#popup1').fadeIn().css({ 'width': Number( 600 ) }).prepend('<a href="#" class="close"><img src="" class="btn_close" title="Close Window" alt="Close" /></a>');		

	var popMargTop = ($('#popup1').height() + 80) / 2;
	var popMargLeft = ($('#popup1').width() + 80) / 2;	

	//Apply Margin to Popup
	$('#popup1').css({
					'margin-top' : -popMargTop,
					'margin-left' : -popMargLeft,			
					'width':'550px'
				});	

	//Fade in Background
	$('body').append('<div id="fade"></div>'); //Add the fade layer to bottom of the body tag.
	$('#fade').css({'filter' : 'alpha(opacity=80)'}).fadeIn(); //Fade in the fade layer
	return false;
}
//Close Popups and Fade Layer

$('a.close').live('click', function() { //When clicking on the close or fade layer...
						$('#fade , .popup_block').fadeOut(function() {
						$('#fade, a.close').remove();
						$('#popup1').html('<p>Loading....</p>');
						}); //fade them both out
					return false;

			});
			
function close_page()
{
	$('#fade , .popup_block').fadeOut(function() {
		$('#fade, a.close').remove();
		$('#popup1').html('<p>Loading....</p>');
	}); //fade them both out
}
