String.prototype.hashCode = function () {
    var hash = 0, i, chr, len;
    if (this.length === 0) return hash;
    for (i = 0, len = this.length; i < len; i++) {
        chr = this.charCodeAt(i);
        hash = ((hash << 5) - hash) + chr;
        hash |= 0; // Convert to 32bit integer
    }
    return hash;
};

(function ($) {
    $(document).ready(function () {

        /*--------------------------------------------------------------
        # Global
        --------------------------------------------------------------*/

		
		
        $.support.placeholder = (function () {
            var i = document.createElement('input');
            return 'placeholder' in i;
        })();

        /*
          Global Variables
        -------------------------------*/
        var $html = $('html'),
            $body = $('body'),
            $doc = $(document);

        if ($body.hasClass('sfPageEditor')) {
            $('.fe-styles').remove();
            $('head').append('<link href="/Style/css/sitefinity.css" rel="stylesheet"/>');
        }

        if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
            $body.addClass('mobile-device');
        }
if(typeof($("").selectBoxIt) == "function")
{
        $(".maincontent select:not([multiple])").selectBoxIt({
            autoWidth: false,
            // Uses the jQuery 'fadeIn' effect when opening the drop down
            showEffect: "fadeIn",

            // Sets the jQuery 'fadeIn' effect speed to 400 milleseconds
            showEffectSpeed: 300,

            // Uses the jQuery 'fadeOut' effect when closing the drop down
            hideEffect: "fadeOut",

            // Sets the jQuery 'fadeOut' effect speed to 400 milleseconds
            hideEffectSpeed: 300
        });
}
        /*--------------------------------------------------------------
        # Navigation
        --------------------------------------------------------------*/

        /*
          Level Bulding:
        
          adds useful classes to the 
          navigation structure
        -------------------------------*/
        if (!$body.hasClass('sfPageEditor')) {

            $('.mainmenusubs-wrap .mainmenusubs').each(function (i) {
                $('.megawr > .sectioninner > ul', $(this)).appendTo($('#mainnav > div > ul > li:nth-child(' + (i + 1) + ') .megawr .sectioninner'));
            });

        }
		
		$('.leftsidebar .subnav ul ul li').each(function(){

			if($(this).children('ul').length){
				$(this).addClass('has-children');
			}

		});
		  
		$('.subnav a.sfSel').each(function(){
			$(this).parent().addClass('sfSel');
			if($(this).next().is('ul')){
			  $(this).next().addClass('sfSel');
			}
			$(this).parent().parent().prev().removeClass('sfSel');
			$(this).parent().parent().parent().addClass('current-page-parent');
		  });
  

        $('#mainnav ul, .subnav ul').each(function () {

            //caching
            var $this = $(this);

            //Active Trail
            var activeTrail = $this.find('.sfSel').parent();
            activeTrail.addClass('active-trail');

            $this.find('li:last-child').addClass('last');

            //Add class has children
            var hasParent = $this.closest('li');
            if (hasParent.length) {
                hasParent.addClass('haschildren');
                if (!hasParent.children('.droptrigger').length) {
                    hasParent.append('<span class="droptrigger"></span>');
                }
            }

            //Detect level and add class
            var depth = $this.parents('ul').length + 1;
            $this.addClass('navlevel-' + depth);

        });


        // Add class to menu items (.navlevel-1 > li)
        var navClass = '';
        var navClassTemp = '';
        $('#mainnav .navlevel-1>li').each(function () {
            navClassTemp = $(this).children('a').children('span').text();
            navClass = navClassTemp.replace(/[^A-Z0-9]+/ig, "-").toLowerCase();
            $(this).addClass(navClass);
        });




        // Menu hover delay
        $('#mainnav .navlevel-1>li').hover(function () {
            var target = $(this),
                activeLi = $('#mainnav .navlevel-1>li.active-trail');
            timer = setTimeout(function () {
                target.addClass('show-mega');
                activeLi.addClass('is-hover');
            }, 100);
        }, function () {
            if ($(this).hasClass('show-mega')) {
                $(this).removeClass('show-mega');
            }
            else {
                clearTimeout(timer);
            }
            $('#mainnav .navlevel-1>li.active-trail').removeClass('is-hover');
        });

        // function breakList(numOfLists, list){
        //     var listLength = list.find(">li").size();
        //     var numInRow = Math.ceil(listLength / numOfLists);
        //     for (var i=0;i<numOfLists;i++){
        //         var listItems = list.find(">li").slice(0, numInRow);
        //         var newList = $('<ul/>').append(listItems);
        //         $("body").append(newList);
        //     }
        // }


        // $('#mainnav .navlevel-1 > li').each(function(){
        //     var oldList = $(this).find(".navlevel-2");
        //     var listLength = oldList.children(".level2:not(:first-child)").size();
        //     var numInRow = Math.floor(listLength / 4);
        //     for (var i=0;i<4;i++){
        //         var listItems = $(this).find(".level2").slice(0, numInRow);
        //         var newList = $('<ul class="navlevel-2" />').append(listItems);
        //         $(this).find('.megawr > .sectioninner').append(newList);
        //     }
        //     oldList.remove();
        // });


        // var num_cols = 4,
        // container = $('#mainnav .navlevel-2'),
        // listItem = 'li.level2:not(:first-child)',
        // overviewListItem = 'li.level2:first-child',
        // listClass = 'navlevel-2';
        // container.each(function() {
        //     var items_per_col = new Array(),
        //     items = $(this).find(listItem),
        //     overviewItem = $(this).find(overviewListItem),
        //     min_items_per_col = Math.floor(items.length / num_cols),
        //     difference = items.length - (min_items_per_col * num_cols);
        //     for (var i = 0; i < num_cols; i++) {
        //         if (i < difference) {
        //             items_per_col[i] = min_items_per_col + 1;
        //         } else {
        //             items_per_col[i] = min_items_per_col;
        //         }
        //     }
        //     for (var i = 0; i < num_cols; i++) {
        //         $(this).append($('<ul ></ul>').addClass(listClass));
        //         for (var j = 0; j < items_per_col[i]; j++) {
        //             var pointer = 0;
        //             for (var k = 0; k < i; k++) {
        //                 pointer += items_per_col[k];
        //             }
        //             $(this).find('.' + listClass).last().append(items[j + pointer]);
        //         }
        //     }
        //     overviewItem.next().prepend(overviewItem);
        //     $(this).children('.navlevel-2').unwrap();
        // });


        /*
          Triggers
        -------------------------------*/

        //Menu
        var triggerMenu = $('a.tb-menu');
        triggerMenu.on('click', function (event) {
            event.preventDefault();
            $body.addClass('activate-nav');
        });

        //Trigering Events "drawers"
        $('.droptrigger').on('click', function () {
            var list = $(this).parent();

            if (list.closest('ul').hasClass('navlevel-1')) {

                if (list.hasClass('active')) {
                    list.find('.megawr').slideUp('300', 'swing');
                    list.removeClass('active');
                }
                else {
                    $('.navlevel-1 > li').removeClass('active');
                    $('.navlevel-1 > li .megawr').slideUp('300', 'swing');
                    list.find('.megawr').slideDown('300', 'swing');
                    list.addClass('active');
                }

            }
            else {

                if (list.hasClass('active')) {
                    list.children('ul').slideUp('300', 'swing');
                    list.removeClass('active');
                }
                else {
                    list.siblings().removeClass('active');
                    list.siblings().children('ul').slideUp('300', 'swing');
                    list.children('ul').slideDown('300', 'swing');
                    list.addClass('active');
                }

            }

        });

        //Untrigger
        var untrigger = $('div.overlaytrigger, #menu-close');
        untrigger.on('click', function (event) {
            event.preventDefault();
            $body.removeClass('activate-nav');
            $('#mainnav .active').removeClass('active').find('>ul').attr('style', '');
        });

        //Search
        var triggerSearch = $('a.tb-search');
        triggerSearch.on('click', function (event) {
            event.preventDefault();
            if ($('body.HomePage').length) {
                $('#homesearch').toggleClass('hide-homesearch');
            }
            else {
                $body.toggleClass('activate-search');
            }

        });

        if ($.support.placeholder) {
            var checkSearchExist = setInterval(function () {
                if ($('form.gsc-search-box').length) {
                    $('table.gsc-search-box input.gsc-input').attr('placeholder', 'Search City of Nanaimo.ca');
                    clearInterval(checkSearchExist);
                }
            }, 50); // check every 50ms
        }
        else {
            var checkSearchExist = setInterval(function () {
                if ($('form.gsc-search-box').length) {
                    $('table.gsc-search-box input.gsc-input').val('Search City of Nanaimo.ca');
                    clearInterval(checkSearchExist);
                }
            }, 50); // check every 50ms
        }


        //Close multiple using the document
        $doc.click(function (event) {
            if (!$(event.target).closest('#search-header').length && !$(event.target).is(triggerSearch)) {
                $body.removeClass('activate-search');
            }
        });

        // Footer Navigation
        // $('.footernav > ul').isotope({
        //   // options
        //   itemSelector: 'li.level1',
        //   layoutMode: 'fitRows'
        // });

        var waitForFinalEvent = (function () {
            var timers = {};
            return function (callback, ms, uniqueId) {
                if (!uniqueId) {
                    uniqueId = "Don't call this twice without a uniqueId";
                }
                if (timers[uniqueId]) {
                    clearTimeout(timers[uniqueId]);
                }
                timers[uniqueId] = setTimeout(callback, ms);
            };

        })();

        $(window).on('load resize', function () {

            waitForFinalEvent(function () {

                var rowMaxHeight = 0,
                itemMargin = 0,
                arrItemHeight = [],
                j = 0;
                $('.footernav .level1').each(function (i) {
                    arrItemHeight[j++] = $(this).outerHeight();
                    if (i < 4) {
                        if ($(this).outerHeight() >= rowMaxHeight) {
                            rowMaxHeight = $(this).outerHeight();
                        }
                    }
                });
                $('.footernav .level1').each(function (i) {
                    if (i >= 4) {
                        $(this).css({
                            'margin-top': -(rowMaxHeight - arrItemHeight[i - 4])
                        });
                    }
                });

            }, 100);

        });



        // Responsive Table
        if (!$body.hasClass('sfPageEditor')) {
            $('#content table:not(.rcMainTable,#app-main-content table),#content table.standard-table').each(function(){
				var colCount = 0;
				$(this).find('tr:first td,tr:first th').each(function(){
					 if ($(this).attr('colspan')) {
						colCount += +$(this).attr('colspan');
					} else {
						colCount++;
					}
				});
				if (colCount > 2)
				{
					$(this).stacktable();	
				}
				
			});
			
        }


        /*--------------------------------------------------------------
        # Sliders 
        --------------------------------------------------------------*/
        if ($('.slides').length) {
            var autoPlay = $('.autoPlay').val() == "true";
            var autoPlaySpeed = $('.autoPlaySpeed').val();
            var showThumbnail = $('.showThumbnail').val() == "true";
            var showDot = $('.showDot').val() == "true";
            var showArrow = $('.showArrow').val() == "true";
            var fade = $('.isFade').val() == "true";

            var $sliders = $('.slides');
            $sliders.slick({
                dots: showDot,
                autoplay: autoPlay,
                autoplaySpeed: autoPlaySpeed,
                arrows: showArrow,
                fade: fade
            });

            if (showThumbnail) {
                var $slidersNav = $('.slides-nav');
                $slidersNav.slick({
                    slidesToShow: 5,
                    slidesToScroll: 1,
                    asNavFor: '.slides',
                    centerMode: true,
                    focusOnSelect: true,
                    arrows: !showArrow
                });

            }

            if ($html.hasClass('ie8')) {
                setTimeout(function () {
                    $(window).trigger('resize');
                    $('body').addClass('loaded');
                }, 1000);
            }
        }
        /*--------------------------------------------------------------
        # Lists
        --------------------------------------------------------------*/
        var $overviewBlock = $('li.overviewBlock').first();
        if ($overviewBlock.length) {
            $overviewBlock.parent().addClass('overview-blocks-wrapper');
        }

        /*--------------------------------------------------------------
        # Tabs
        --------------------------------------------------------------*/


        /*
          Tabs generator
        -------------------------------*/
        var tabs = $('.tabs');

        if (tabs.length) {

            var url = window.location.href;
            if (url.indexOf('Action/Edit') == -1) {
                tabs.each(function () {

                    var $this = $(this);

                    //wrap the content divs into their own section
                    //$this.wrapInner('<ul class="tabs-accordion cf"></ul>');

                    //defining variables
                    var tabsItem = $this.find('>.tabs-accordion>div'),
                    tabsNav = [],
                    tabFirst = true;

                    //for each tabs item
                    tabsItem.each(function (i) {

                        //define the variables
                        var $this = $(this),
                            tabTitle = $this.data('placeholder-label'),
                            tabID = tabTitle.replace(/[^a-zA-Z0-9]/g, '_'); //tabTitle.replace('&', '').toLowerCase().replace(/\s+/g, '').split('_');

                        //add Identifier to parent div
                        if (tabFirst) {
                            var mytab = buildtabNavItem($this, tabID, tabTitle, true);
                            tabFirst = false;
                        } else {
                            var mytab = buildtabNavItem($this, tabID, tabTitle, false);
                        }

                    });

                    //inform our tabs have been generated
                    $this.addClass('ready');
                });
            }
        }

        //Function for adding attributes and generating nav item
        function buildtabNavItem(tab, tabID, tabTitle, firstItem) {

            if (firstItem) {
                var tabClass = 'tab is-selected';
                var panelClass = 'panel';
            } else {
                var tabClass = 'tab';
                var panelClass = 'panel is-hidden';
            }

            tab.wrap('<li><div id="panel-' + tabID + '" class="' + panelClass + '" role="tabpanel" aria-labelledby="tab-' + tabID + '" aria-hidden="' + firstItem + '"></div></li>');

            $('<a id="tab-' + tabID + '" href="javascript:void(0)" class="' + tabClass + '" aria-controls="panel-' + tabID + '" aria-selected="' + firstItem + '" role="tab"><span>' + tabTitle + '</span></a>').prependTo(tab.parent().parent());

        }


        /*
          Tabs functionality
        -------------------------------*/
        var url = window.location.href;
        if (url.indexOf('Action/Edit') == -1) {// not in edit mode

            var tabLink = $('a[role="tab"]');

            //regular click
            tabLink.on('click', function () {

                triggerTab($(this));

            });

            //on enter
            tabLink.keydown(function (ev) {
                if (ev.which == 13) {
                    $(this).click()
                }
            });

            function triggerTab($this) {

                //defining variables
                var $this = $this,
                    $selected = $this.closest('.tabs').find('.tab.is-selected');
                tabId = $this.attr('aria-controls');
                $panel = $this.closest('.tabs').find('.panel');
                tabpan = $('#' + tabId);

                //deselect all the tabs and panels
                $selected.removeClass('is-selected').attr('aria-selected', 'false');
                $panel.addClass('is-hidden').attr('aria-hidden', 'true');

                // select this tab and panel
                $this.addClass('is-selected').attr('aria-selected', 'true');
                tabpan.removeClass('is-hidden').attr('aria-hidden', 'false');

            }



            /*--------------------------------------------------------------
            # Sticky elements
            --------------------------------------------------------------*/

            /*
              Header
              Uncomment to enable
            -------------------------------
        
            $('.h-w1')
                .stick_in_parent({
                    parent: $('#wrapper'),
                    offset_top: -160,
                    bottoming: false
                })
                .on("sticky_kit:stick", function () {
                    $(this).removeClass('fadeInUp').addClass('slideInDown');
                })
                .on("sticky_kit:unstick", function () {
                    $(this).removeClass('slideInDown').addClass('fadeIn');
                });*/


            /*--------------------------------------------------------------
            # Video Pop Up using magnific popup from sitefinity
            --------------------------------------------------------------*/

            $(".playLink").magnificPopup({ type: 'iframe' });

            $('.photogallery').magnificPopup({
                delegate: 'a',
                type: 'image',
                tLoading: 'Loading image #%curr%...',
                mainClass: 'mfp-img-mobile',
                gallery: {
                    enabled: true,
                    navigateByImgClick: true,
                    preload: [0, 1] // Will preload 0 - before current, and 1 after the current image
                },
                image: {
                    tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
                    //titleSrc: function(item) {
                    //  return item.el.attr('title') + '<small>by Marsel Van Oosten</small>';
                    //}
                }
            });
        } else {
            //alert("edit mo");
        }




        /*--------------------------------------------------------------
        # Scrolling
        --------------------------------------------------------------*/

        $(function () {
            $('a[href*="#"]:not([href="#"],#app-main-content a)').click(function () {
            
                if (location.pathname.replace(/^\//, '') == this.pathname.replace(/^\//, '') && location.hostname == this.hostname) {
                    var target = $(this.hash);
                    target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
                    if (target.length) {
                        $('html,body').animate({
                            scrollTop: target.offset().top
                        }, 600);
                        return false;
                    }
                }
            });
        });


        $('.overview-blocks').parent().parent().addClass('ov-blocks');






        /*--------------------------------------------------------------
        # Page Wrong
        --------------------------------------------------------------*/
        $('#pw-form-toggle').on('click', function (e) {
            e.preventDefault();
			$('.sfFormBox label:contains("Current Page")').parents('.sfFormBox').hide().find('input').val(window.location.href);
            $('.page-wrong').toggleClass('show-form');
        });
        if ($('.page-wrong .sfSuccess *').length) {
            $('.page-wrong').addClass('show-msg');
        }



        /*--------------------------------------------------------------
        # Top Message
        --------------------------------------------------------------*/
        $('#alertmessagewrp .close').on('click', function (e) {
            e.preventDefault();
            $('#alertmessagewrp').slideUp(200);
            //  var d = new Date();
            //  d.setTime(d.getTime() + (1 * 24 * 60 * 60 * 1000));
            //  var expires = "expires=" + d.toUTCString();
            //  document.cookie = "alertmsgread" + "=" + "yes" + "; " + expires;

            //grab the text we will use this as the cookie key to track for changes
            var messageText = $('#alertmessagewrp .messagetitle').text().trim();

            //message is informational- close for a week
            if ($('#alertmessagewrp li.Information').length > 0) {
                var expires = new Date();
                expires.setTime(expires.getTime()+(7*24*60*60*1000))
                document.cookie = "alertmsgset" + "=" + messageText.hashCode() + ";expires=" + expires.toGMTString();
            } else {
                //important messages only last till the next browser close.
                document.cookie = "alertmsgset" + "=" + messageText.hashCode();
            }
            

            //setTimeout(function () {
            //    $('#alertmessagewrp').removeClass("alertmsgShow").removeAttr('style');
            //}, 200)


        });
        //check if there is a message
        var msgTitile
        if ($('#alertmessagewrp .messagetitle').length > 0) {
            
            var checkisalertmsgClosed = getCookie("alertmsgset");
            var messageText = $('#alertmessagewrp .messagetitle').text().trim();
            if (checkisalertmsgClosed != messageText.hashCode()) {
                $('#alertmessagewrp').addClass("alertmsgShow");

            }
        }



        // if (Modernizr.inputtypes.date) {
        // // If not native HTML5 support, fallback to jQuery datePicker
        //     $('.RadPicker .RadInput>input').datepicker({
        //         // Consistent format with the HTML5 picker

        //         },
        //         // Localization
        //         $.datepicker.regional['it']
        //     );
        // }
        // else{

        // }





        /*--------------------------------------------------------------
        # Homepage
        --------------------------------------------------------------*/
        if ($('body.HomePage').length) {
			
			$.fn.randomize = function(selector){
			  var $elems = selector ? $(this).find(selector) : $(this).children(),
				  $parents = $elems.parent();

			  $parents.each(function(){
				  $(this).children(selector).sort(function(){
					  return Math.round(Math.random()) - 0.5;
				  }).detach().appendTo(this);
			  });

			  return this;
			};

			// randomize the slides and then call slick

            $('#masthead .sflist').randomize().slick({
                dots: false,
                autoplay: true,
                autoplaySpeed: 8000,
                speed: 1000,
                arrows: true
            });


            // Custom News Slider
            var numOfCols = 0;
            var itemPerCol = 5;

            var checkHomeNewsExist = setInterval(function () {

                if ($('.home-news-list > ul').length) {

                    numOfCols = Math.ceil($('.home-news-list > ul > li').length / itemPerCol);

                    $('.home-news-list > ul').prepend($('<li class="news-cols-wrap"></li>'));

                    for (var i = 1; i <= numOfCols; i++) {
                        $('.home-news-list .news-cols-wrap').append($('<ul class="news-col col-' + i + '"></ul>'));
                    }

                    var k = 1;
                    var l = itemPerCol;
                    $('.home-news-list > ul > li').each(function (j) {

                        if (j > 0) {

                            if (j > l) { k++; l = itemPerCol * k }

                            $(this).appendTo($('.home-news-list .news-cols-wrap .news-col.col-' + k));

                        }
                    });

                    clearInterval(checkHomeNewsExist);

                }

            }, 50); // check every 50ms


        }








        /*-------------------------------------------------------------
        # Responsive JS
        ---------------------------------------------------------------*/

        enquire.register("screen and (max-width:767px)", {

            // OPTIONAL
            // If supplied, triggered when a media query matches.
            match: function () {

                $('#util .loginUtil').prependTo($('#header .mobilenav-triggers'));
                $('#util').appendTo($('#navsection .navblock'));
                $('#footer .f-w1 .social-links').prependTo($('#footer .f-w3 .textf > div'));



                // Homepage
                if ($('body.HomePage').length) {

                    $('#homesearch').insertBefore($('#masthead'));
                    $('.top-requests').prependTo($('.maincontent'));
                    $('.cta-wrap').insertAfter($('.top-requests'));

                    if ($('.home-events-list > ul.slick-slider').length) {
                        $('.home-events-list > ul').slick('unslick');
                    }
                    if ($('.home-news-list .news-cols-wrap.slick-slider').length) {
                        $('.home-news-list .news-cols-wrap').slick('unslick');
                    }
                    if ($('.home-events-list > ul.slick-slider').length) {
                        $('.home-events-list > ul').slick('unslick');
                    }

                }


                // Project Details Page
                $('.tab-content .content-inner').removeAttr('style');
                $('.tab-content .active .content-inner').slideDown(300);
                $('.tabs a').off('click');

                $('.tab-content > ul > li > a').on('click', function (e) {
                    e.preventDefault();

                    if ($(this).parent().hasClass('active')) {
                        //$('.tabs a, .tab-content > ul > li').removeClass('active');
                        //$(this).next('.content-inner').slideUp(300);
                    }
                    else {
                        $('.tab-content .active .content-inner').slideUp(300);
                        $('.tabs a, .tab-content > ul > li').removeClass('active');
                        $(this).next('.content-inner').slideDown(300);
                        var targetClass = $(this).parent().attr('class');
                        $(this).parent().addClass('active');
                        $('.tabs li[class="' + targetClass + '"] a').addClass('active');
                    }
                });


            },

            // OPTIONAL
            // If supplied, triggered when the media query transitions 
            // *from a matched state to an unmatched state*.
            unmatch: function () { },

            // OPTIONAL
            // If supplied, triggered once, when the handler is registered.
            setup: function () { },

            // OPTIONAL, defaults to false
            // If set to true, defers execution of the setup function 
            // until the first time the media query is matched
            deferSetup: true,

            // OPTIONAL
            // If supplied, triggered when handler is unregistered. 
            // Place cleanup code here
            destroy: function () { }

        });

        enquire.register("screen and (min-width:768px)", {

            // OPTIONAL
            // If supplied, triggered when a media query matches.
            match: function () {
                $('#header .mobilenav-triggers .loginUtil').appendTo($('#util > .section-inner'));
                $('#navsection #util').insertAfter($('#logo'));
                $('#footer .f-w3 .social-links').appendTo($('#footer .f-w1 .f-col1 > div'));
                $('.leftsidebar ul, #mainnav ul, .megawr').removeAttr('style');
                $('#homesearch').removeClass('hide-homesearch');


                // Homepage
                if ($('body.HomePage').length) {

                    $('#homesearch').insertAfter($('#masthead'));
                    $('.top-requests').prependTo($('.leftsidebar'));
                    $('.cta-wrap').insertAfter($('.top-requests'));

                    var checkHomeNewsDesktop = setInterval(function () {

                        if ($('.home-news-list .news-cols-wrap .news-col').length) {

                            $('.home-news-list .news-cols-wrap').slick({
                                dots: false,
                                autoplay: false,
                                arrows: true,
                                infinite: false,
                                slidesToShow: 1,
                                slidesToScroll: 1,
                            });

                            clearInterval(checkHomeNewsDesktop);

                        }

                    }, 50); // check every 50ms


                    $('.home-events-list > ul').slick({
                        dots: false,
                        autoplay: false,
                        arrows: true,
                        infinite: false,
                        slidesToShow: 2,
                        slidesToScroll: 2
                    });

                }


                // Project Details Page
                $('.tab-content .content-inner').removeAttr('style');
                $('.project-details .tab-content > ul > li > a').off('click');

                $('.tabs a').on('click', function (e) {
                    e.preventDefault();
                    $('.tabs a, .tab-content > ul > li').removeClass('active');
                    $(this).addClass('active');
                    var targetClass = $(this).parent().attr('class');
                    $('.tab-content > ul > li[class~="' + targetClass + '"]').addClass('active');
                });


            },

            // OPTIONAL
            // If supplied, triggered when the media query transitions 
            // *from a matched state to an unmatched state*.
            unmatch: function () { },

            // OPTIONAL
            // If supplied, triggered once, when the handler is registered.
            setup: function () { },

            // OPTIONAL, defaults to false
            // If set to true, defers execution of the setup function 
            // until the first time the media query is matched
            deferSetup: true,

            // OPTIONAL
            // If supplied, triggered when handler is unregistered. 
            // Place cleanup code here
            destroy: function () { }

        });

    });
})(jQuery);

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

