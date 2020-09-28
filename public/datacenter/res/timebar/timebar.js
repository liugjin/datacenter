/*!
  jQuery timebar plugin
  @name jquery.timebar.js
  @author pulkitchadha (pulkitchadha27@gmail.com]
  @version 1.0
  @date 28/03/2018
  @category jQuery Plugin
  @copyright (c) 2018 pulkitchadha (pulkitchadha)
  @license Licensed under the MIT (http://www.opensource.org/licenses/mit-license.php) license.
*/
(function ($) {
	$.fn.timebar = function (options) {
		var self = this;

		options = $.extend($.fn.timebar.defaults, options);

		$.fn.timebar.defaults.element = self;

		// methods
		this.getSelectedTime = function () {
			return $.fn.timebar.defaults.selectedTime;
		};
		this.setSelectedTime = function (time) {
			if (!time && time !== 0) throw new Error('please pass the valid time');

			$.fn.timebar.defaults.selectedTime = parseInt(time);
			return this;
		};
		this.getTotalTime = function () {
			return $.fn.timebar.defaults.totalTimeInSecond;
		};
		this.setTotalTime = function (time) {
			if (!time) throw new Error('please pass the valid time');

			$.fn.timebar.defaults.totalTimeInSecond = parseInt(time);
			return this;
		};
		this.getWidth = function () {
			return $.fn.timebar.defaults.width;
		};
		this.setWidth = function (width) {
			if (!width) throw new Error('please pass the valid width');

			$.fn.timebar.defaults.width = width;
			width = this.getActualWidth() + 57;
			$(".timeline-cover").css('width', width + 'px');
			return this;
		};
		this.getActualWidth = function () {
			var width = $.fn.timebar.defaults.width;
			width = parseInt(width.replace(/px|%/g, ''));
			return width;
		}
		this.getCuepoints = function () {
			return $.fn.timebar.defaults.cuepoints;
		}
		this.formatTime = function (sec_num) {
			return toDuration(sec_num);
		}
		this.addCuepoints = function (cuepoint) {
			if (!cuepoint) throw new Error('please pass the valid time');

			cuepoint = parseInt(cuepoint);

			if (!$.fn.timebar.defaults.cuepoints.includes(cuepoint)) {
				$.fn.timebar.defaults.cuepoints.push(cuepoint);
				markCuepoints(cuepoint);
			} else {
				throw new Error('Cuepoint already exists');
			}

			return this;
		}
		
		this.updateSelectedCuepoint = function (cuepoint) {
			var selectedCuepoints = [];

			$(".pointerSelected").each(function () {
				var id = $(this).attr("id");
				selectedCuepoints.push(parseInt(id));
			});

			if (selectedCuepoints.length > 1) throw new Error('Please select only one cuepoint to update');

			this.deleteSelectedCuepoints();

			this.addCuepoints(cuepoint);

			return this;
		}
		this.showHideCuepoints = function (show) {
			if (!show) throw new Error('please pass a valid value');

			parseBoolean(show) ? $(".pointer").show() : $(".pointer").hide();

			return this;
		}

		// events

		return self.each(function () {
			init(self);

			// When user clicks on timebar
			$(this).on('click', '.step', function (event) {
				self.setSelectedTime($(this).data("time"));

				if (typeof options.barClicked === 'function') {
					options.barClicked.call(this, self.getSelectedTime());
				}
			});

			// Move the step to the clicked positon
			$(this).on('click', '.steps-bar', function (event) {
				barClicked(this, event, self);
			});

			// when user clicks on cuepoints
			$(this).on("click", '.pointer', function () {
				var options = $.fn.timebar.defaults;

				$(this).hasClass("pointerSelected") ? $(this).removeClass("pointerSelected") : $(this).addClass("pointerSelected");

				self.setSelectedTime($(this).data("time"));

				if (typeof options.pointerClicked === 'function') {
					options.pointerClicked.call(this, self.getSelectedTime());
				}
			});
		});
	};

	$.fn.timebar.defaults = {
		//properties
		element: null,
		totalTimeInSecond: 0,
		cuepoints: [],
		width: 0,
		globalPageX: 0,
		selectedTime: 0,
		multiSelect: false,
		showCuepoints: true,
		stepBars: 120,
		timeIntervals: 12,
		// events
		barClicked: null,
		pointerClicked: null,

		//Currently, Not supported

		// life cycle methods
		beforeCreate: null,
		created: null,
		beforeMount: null,
		mounted: null,
		beforeUpdate: null,
		updated: null,
		// hooks
		beforeAddCuepoint: null,
		afterAddCuepoint: null,
		beforeUpdateCuepoint: null,
		afterUpdateCuepoint: null,
		beforeDeleteCuepoint: null,
		afterDeleteCuepoint: null,
	};

	function init(ele) {

		var options = $.fn.timebar.defaults;

		var data = '';

		//time bar
		data += '<div class="timeline-cover"><div id="draggable"></div><div class="timeline-bar"><div class="steps-bar clearfix"></div>	</div></div>';

		$(options.element).append(data);

		ele.setWidth(options.width);

		var timeDivison = options.totalTimeInSecond / options.stepBars;
		var time = 0;

		// mark bars
		for (var i = 0; i <= options.stepBars; i++) {
		
			$(".steps-bar").append("<div class='step' data-time="+time+"><span class='step-border'></span></div>");
			time = time + timeDivison;
		}

		var markTimeDivison = options.totalTimeInSecond / options.timeIntervals;

		// mark time intervals
		for (var i = 0; i <= options.timeIntervals; i++) {
			var time = toDuration(Math.round(markTimeDivison * i));
			var pos = i * 10 + 1;
		
			$(".step:nth-child(" + pos + ")").append("<span class='time-instant'>"+ time +"</span>");
		}

		

		if (!options.showCuepoints) {
			$(".pointer").hide();
		}
	}

	function toDuration(sec_num) {
		var hours = Math.floor(sec_num / 3600);
		var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
		var seconds = sec_num - (hours * 3600) - (minutes * 60);
		if (hours < 10) {
			hours = "0" + Math.round(hours);
		}
		if (minutes < 10) {
			minutes = "0" + Math.round(minutes);
		}
		if (seconds < 10) {
			seconds = "0" + Math.round(seconds);
		}
		//var time = (hours == 00) ? minutes + ':' + seconds : hours + ':' + minutes + ':' + seconds;
		var time = hours +':' + minutes + ':' + seconds;
		return time;
	}

	

	function barClicked(element, event, self) {

		var offset = $(element).offset();
		var offsetLeft = (event.pageX - offset.left);

		$('.pointer').removeClass("pointerSelected");

		$("#draggable").css({
			left: offsetLeft+'px'
		});
	};

	function parseBoolean(val) {
		return (val.toLowerCase() === 'true');
	}

}(jQuery, window));