$(function () {
    $('.tlt').textillate({
	    minDisplayTime: 1500,
        initialDelay: 500,
	    in: {
            effect: 'fadeInLeft',
            sync: false
        },
	    out :{
            delay: 3,
            effect: 'fadeOut',
            sync: false,
        },

	    loop: true
	});
});
