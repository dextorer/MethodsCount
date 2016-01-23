function request(verb, path, onsuccess, onfail) {
   var xhr = new XMLHttpRequest();
   xhr.open(verb, path, true);
   xhr.onload = function (e) {
      if (xhr.readyState === 4) {
         if (xhr.status === 200) {
            onsuccess(xhr.response)
         } else {
            onfail(xhr.statusText);
         }
      }
   };
   xhr.onerror = function (e) {
      onfail(xhr.statusText);
   };
   xhr.send(null);
}


var windowId;

function startMessageCycling() {
   var currentIndex = 1;
   $('#progress-message').text(loadingMessages[0]);
   $('#progress-message').css('visibility', 'visible');
   windowId = setInterval(function() {
      $('#progress-message').fadeOut('fast', function() {
         $('#progress-message').text(loadingMessages[currentIndex++]);
         if (currentIndex >= loadingMessages.length) {
            currentIndex = 0;
         }
         $('#progress-message').fadeIn();
      });
   }, 10000);
}


function stopMessageCycling() {
   clearInterval(windowId);
}

function submitLibraryRequest(libraryName) {
   // sanitize
   libraryName = libraryName.replace(/(@aar|@jar)$/, "");
   console.log(libraryName);
   if ($('#welcome-card-container').css('visibility') == 'visible') {
      $('#welcome-card-container').fadeOut('fast', function() {
         $('#welcome-card-container').css('display', 'none');
      });
   }

   if ($('#result-card-container').css('visibility') == 'visible') {
      $('#result-card-container').fadeOut('fast', function() {
         $('#result-card-container').css('display', 'none');
      });
   }
   
   if ($('#error-card-container').css('visibility') == 'visible') {
      $('#error-card-container').fadeOut('fast', function() {
         $('#error-card-container').css('display', 'none');
      });
   }

   $('#tab-main').trigger('click');
   $('#search-box').trigger('blur');

   $('#progress-card-container').css('visibility','visible').hide().fadeIn();
   startMessageCycling();

   request(
         "POST",  
         "/api/request/" + libraryName, 
         function(response) {
            obj = JSON.parse(response);
            console.log("Successfully enqeueud job for " + obj["lib_name"]);
            window.history.pushState(libraryName, libraryName, "/?lib=" + encodeURIComponent(libraryName));
            $('#progress-card-container').css('visibility','visible').hide().fadeIn();
            poll(libraryName);
         },
         function(errorText) {
            console.error(errorText);
            stopMessageCycling();
         }
   );
}


function poll(libraryName) {
   request("GET", "/api/stats/" + libraryName,
         function(response) {
            obj = JSON.parse(response);
            if (obj["status"] == "done") {
               console.log("Done");
               console.log(obj)
               $('#progress-card-container').fadeOut('fast', function() {
                  $('#progress-card-container').css('display', 'none');
               });
               stopMessageCycling();
               $('#result-card-container').css('visibility','visible').hide().fadeIn();
               showResponse(obj.result);
            } else if (obj["status"] == "error" || obj["status"] == "undefined") {
               console.log("Error");
               console.log(obj)
               $('#progress-card-container').fadeOut('fast', function() {
                  $('#progress-card-container').css('display', 'none');
               });
               stopMessageCycling();
               $('#error-card-container').css('visibility','visible').hide().fadeIn();
            } else {
               setTimeout(function() {
                  poll(libraryName);
               }, 2000);
            }
         },
         function(errorText) {
            console.error(errorText);
         });
}


function mockRequest() {
   // simulate load time so to visualize progress
   if ($('#welcome-card-container').css('visibility') == 'visible') {
      $('#welcome-card-container').fadeOut('fast', function() {
         $('#welcome-card-container').css('display', 'none');
      });
   }

   if ($('#result-card-container').css('visibility') == 'visible') {
      $('#result-card-container').fadeOut('fast', function() {
         $('#result-card-container').css('display', 'none');
      });
   }
   
   if ($('#error-card-container').css('visibility') == 'visible') {
      $('#error-card-container').fadeOut('fast', function() {
         $('#error-card-container').css('display', 'none');
      });
   }

   $('#progress-card-container').css('visibility','visible').hide().fadeIn();

   var timeoutID = window.setTimeout(function() {
      $('#progress-card-container').fadeOut();

      var raw_resp = '{"library_fqn":"com.wnafee:vector-compat:1.0.5","library_methods":609,"library_size":87234,"dependencies_count":3,"dependencies":[{"dependency_name":"com.android.support:appcompat-v7:22.1.0","dependency_count":5162,"dependency_size":829066},{"dependency_name":"com.android.support:support-annotations:22.1.0","dependency_count":3,"dependency_size":11467},{"dependency_name":"com.android.support:support-v4:22.1.0","dependency_count":7876,"dependency_size":1005480}]}';
      var response = JSON.parse(raw_resp);

      $('#result-card-container').css('visibility','visible').hide().fadeIn();
      showResponse(response);
   }, 2000);
}


function showResponse(result) {
   var response = result;
   
   $('#result-card-dep-list').empty();
   var dependencies = response.dependencies;
   var total_count = 0;
   var total_size = 0;
   var total_dex_size = 0;
   if (dependencies.length > 0) {
      dependencies.forEach(function(dependency) {
         $('#result-card-dep-list').append("<li><div><p>" + dependency.dependency_name + "</p><div class=\"indent-right\"><blockquote><p>Methods count: " + dependency.dependency_count + "</p><p>Size: " + Math.ceil(dependency.dependency_size / 1000) + " KB</p><p>DEX size: " + Math.ceil(dependency.dependency_dex_size / 1000) + " KB</p></blockquote></div></div></li>");
         total_count += dependency.dependency_count;
         total_size += dependency.dependency_size;
         total_dex_size += dependency.dependency_dex_size;
      });
      $('#result-dependency-summary tr').has('td').remove();
      $('#result-dependency-summary').append("<tr><td>" + total_count + "</td><td>" + Math.ceil(total_size / 1000) + "</td><td>" + Math.ceil(total_dex_size / 1000) + "</td></tr>");
      $('#result-card-dep-container').show();
      $('#result-dep-summary-container').show();
   } else {
      $('#result-card-dep-container').hide();
      $('#result-dep-summary-container').hide();
   }

   $('#result-library-summary tr').has('td').remove();
   $('#result-library-summary').append("<tr><td class=\"truncate\">" + response.library_fqn + "</td><td>" + (total_count + response.library_methods) + "</td></tr>");
   $('#result-library-stats tr').has('td').remove();
   $('#result-library-stats').append("<tr><td>" + response.library_methods + "</td><td>" + response.dependencies_count + "</td><td>" + Math.ceil(response.library_size / 1000) + "</td><td>" + Math.ceil(response.library_dex_size / 1000) + "</td></tr>");

   var currentUrl = window.location.href;
   var methodsBadge = ""
   if (total_count > 0) {
      methodsBadge = "core: " + response.library_methods + " | deps: " + total_count + ""
   } else {
      methodsBadge = response.library_methods
   }

   var methodsCode = "<a href=\"" + currentUrl + "\"><img src=\"https://img.shields.io/badge/Methods count-" + methodsBadge + "-e91e63.svg\"></img></a>";
   var sizeCode = "<a href=\"" + currentUrl + "\"><img src=\"https://img.shields.io/badge/Size-" + Math.ceil(response.library_size / 1000) + " KB-e91e63.svg\"></img></a>";
   var allCode = "<a href=\"" + currentUrl + "\"><img src=\"https://img.shields.io/badge/Methods and size-" + methodsBadge + " | " + Math.ceil(response.library_size / 1000) + " KB-e91e63.svg\"></img></a>";

   $('#badge-methods-code').text(methodsCode);
   $('#badge-size-code').text(sizeCode);
   $('#badge-all-code').text(allCode);

   $('#badge-methods-preview').html(methodsCode);
   $('#badge-size-preview').html(sizeCode);
   $('#badge-all-preview').html(allCode);

   $('#share-dropdown-link-code').html(currentUrl);

   $('#share-dropdown-twitter a').attr('href', 'https://twitter.com/intent/tweet?hashtags=MethodsCount&url=' + encodeURIComponent(currentUrl) + '&via=rotxed');
   $('#share-dropdown-gplus a').attr('href', 'https://plus.google.com/share?url=' + encodeURIComponent(currentUrl));
}

$('#search-box').on('keydown', function(e) {
   if (e.which == 13) {
      e.preventDefault();
      $('#search-form').submit();
      //mockRequest();
      }
});

var cache = [];
$.getJSON("/api/top/", function(data) {
   data.forEach(function(elem) {
      cache.push(elem.fqn);
   });
});

var options = {
   data: cache,
   list: {
      match: {
         enabled: true
      },
      maxNumberOfElements: 10,
      onClickEvent: function() {
         submitLibraryRequest($('#search-box').val());
      },
      onLoadEvent: function() {
         //$('#result-card-container').fadeOut();
         //$('#welcome-card-container').fadeOut();      
      }
   }
};
$('#search-box').easyAutocomplete(options);

$('#result-card-dep-list-title').click(function() {
    $('#result-card-dep-list').slideToggle('slow');
});

$('#search-button').click(function() {
   $('#search-form').submit();
});

$('#try-now').click(function() {
   $('#search-box').val("com.github.dextorer:sofa:1.0.0");
   $('#search-button').trigger('click');
});

$('#supported-libs-link').click(function() {
   $('#tab-about').click();
   setTimeout(function(){
            $(window).scrollTop($('#supported-libs').offset().top);;
        },1000);
});

$.validate({
   showHelpOnFocus: false,
   addSuggestions: false,
   validateOnBlur: false,
   onError: function($form) {
      Materialize.toast("This looks invalid! Please stick to group_id:artifact_id:version ('+' is supported)", 3000);
   },
   onSuccess: function($form) {
      submitLibraryRequest($('#search-box').val());
   }
});

var mainContainer = $('#main-container');
var pluginContainer = $('#plugin-container');
var aboutContainer = $('#about-container');

$('#tab-main').click(function() {
   var sPath = window.location.pathname;
   var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
   if (sPage != "" && sPage != "index.html") {
      window.location.replace("/");
   }
});

$('#tab-plugins').click(function() {
   var sPath = window.location.pathname;
   var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
   if (sPage != "plugins.html") {
      window.location.replace("/plugins.html");
   }
});

$('#tab-about').click(function() {
   var sPath = window.location.pathname;
   var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
   if (sPage != "about.html") {
      window.location.replace("/about.html");
   }
});

var loadingMessages = [
   "This may take a while... Grab a coffee, perhaps?",
   "Gradle and DX require some time to do their magic.",
   "Results are and will be cached. Next time is going to be much faster!",
   "Still processing, hang on...",
   "You can leave me here and come back in a while, no worries"
];

// query params
var getUrlParameter = function getUrlParameter(sParam) {
   var sPageURL = decodeURIComponent(window.location.search.substring(1)),
         sURLVariables = sPageURL.split('&'),
         sParameterName,
         i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
         return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
};

$(document).ready(function() {
   var reqLib = getUrlParameter("lib");
   if (reqLib) {
      $('#search-box').val(reqLib);
      $('#search-button').trigger("click");
   }
});

$(document).ready(function() {
   var sPath = window.location.pathname;
   var sPage = sPath.substring(sPath.lastIndexOf('/') + 1);
   if (sPage == "plugins.html") {
      $('#tab-plugins a').trigger('click');
   } else if (sPage  == "about.html") {
      $('#tab-about a').trigger('click');
   } else {
      $('#tab-main a').trigger('click');
   }
});

$(document).ready(function() {
   $('.modal-trigger').leanModal({
      ready: function() { 
         $('#donate-gif').click(function() { $('#bitcoin-donate-button').trigger('click'); }); 
         var btcAddresses = ["188HuCKxwwkJyeubke2CELBZKhj7B4cqeY", "15WUrFsBLSBwDXt3dDJ8oAizMNftCdY2Rd"];
         var maximum = 1;
         var minimum = 0;
         var randomIndex = Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
         $('#bitcoin-donate-button').attr("data-address", btcAddresses[randomIndex]);
      }
   });
});

hljs.initHighlightingOnLoad();


