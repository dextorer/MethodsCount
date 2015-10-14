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


function submitLibraryRequest(libraryName) {
   if ($('#welcome-card-container').css('visibility') == 'visible') {
      $('#welcome-card-container').fadeOut();
   }

   if ($('#result-card-container').css('visibility') == 'visible') {
      $('#result-card-container').fadeOut();
   }
   
   if ($('#error-card-container').css('visibility') == 'visible') {
      $('#error-card-container').fadeOut();
   }

   $('#progress').css('visibility','visible').hide().fadeIn();

   request(
         "POST",  
         "/api/request/" + libraryName, 
         function(response) {
            obj = JSON.parse(response);
            console.log("Successfully enqeueud job for " + obj["lib_name"]);
            $('#progress').css('visibility','visible').hide().fadeIn();
            poll(libraryName);
         },
         function(errorText) {
            console.error(errorText);
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
               $('#progress').fadeOut();
               $('#result-card-container').css('visibility','visible').hide().fadeIn();
               showResponse(obj.result);
            } else if (obj["status"] == "error") {
               console.log("Error");
               console.log(obj)
               $('#progress').fadeOut();
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


function fetchTopLibraries() {
   request("GET", "/api/top/",
      function(response) {
         console.log("response" + response)
         obj = JSON.parse(response);
         console.log(obj)
      },
      function(errorText) {
         console.error(errorText)
      });
}


function mockRequest() {
   // simulate load time so to visualize progress
   if ($('#welcome-card-container').css('visibility') == 'visible') {
      $('#welcome-card-container').fadeOut();
   }

   if ($('#result-card-container').css('visibility') == 'visible') {
      $('#result-card-container').fadeOut();
   }
   
   if ($('#error-card-container').css('visibility') == 'visible') {
      $('#error-card-container').fadeOut();
   }

   $('#progress').css('visibility','visible').hide().fadeIn();

   var timeoutID = window.setTimeout(function() {
      $('#progress').fadeOut();

      var raw_resp = '{"library_fqn":"com.wnafee:vector-compat:1.0.5","library_methods":609,"library_size":87234,"dependencies_count":3,"dependencies":[{"dependency_name":"com.android.support:appcompat-v7:22.1.0","dependency_count":5162,"dependency_size":829066},{"dependency_name":"com.android.support:support-annotations:22.1.0","dependency_count":3,"dependency_size":11467},{"dependency_name":"com.android.support:support-v4:22.1.0","dependency_count":7876,"dependency_size":1005480}]}';
      var response = JSON.parse(raw_resp);

      $('#result-card-container').css('visibility','visible').hide().fadeIn();
      showResponse(response);
   }, 2000);
}


function showResponse(result) {
   var response = result;
   $('#result-library-stats tr').has('td').remove();
   $('#result-lib-name').text(response.library_fqn);
   $('#result-library-stats').append("<tr><td>" + response.library_methods + "</td><td>" + response.dependencies_count + "</td><td>" + Math.ceil(response.library_size / 1000) + "</td></tr>");

   $('#result-card-dep-list').empty();
   var dependencies = response.dependencies;
   var total_count = 0;
   var total_size = 0;
   if (dependencies.length > 0) {
      dependencies.forEach(function(dependency) {
         $('#result-card-dep-list').append("<li><div><p>" + dependency.dependency_name + "</p><div class=\"indent-right\"><blockquote><p>Methods count: " + dependency.dependency_count + "</p><p>Library size: " + Math.ceil(dependency.dependency_size / 1000) + " KB</p></blockquote></div></div></li>");
         total_count += dependency.dependency_count;
         total_size += dependency.dependency_size;
      });
      $('#result-dependency-summary tr').has('td').remove();
      $('#result-dependency-summary').append("<tr><td>" + total_count + "</td><td>" + Math.ceil(total_size / 1000) + "</td></tr>");
      $('#result-card-dep-container').show();
      $('#result-dep-summary-container').show();
   } else {
      $('#result-card-dep-container').hide();
      $('#result-dep-summary-container').hide();
   }
}

$('#result-card-container').css('visibility', 'hidden')
$('#progress').css('visibility', 'hidden')

$('#search-box').on('keydown', function(e) {
   if (e.which == 13) {
      e.preventDefault();
      submitLibraryRequest($('#search-box').val());
      //mockRequest();
      }
});

var options = {
   url: function(phrase) {
      return "/api/top/";
   },
   list: {
      match: {
         enabled: true
      },
      onClickEvent: function() {
         submitLibraryRequest($('#search-box').val());
      },
      onLoadEvent: function() {
         //$('#result-card-container').fadeOut();
         //$('#welcome-card-container').fadeOut();      
      }
   },
   getValue: "fqn"
};
$('#search-box').easyAutocomplete(options);

$('#search-box').on("focus", function() {
   // has acquired focus
});

$('#search-box').blur(function() {
   //$('#result-card-container').fadeIn();
   //$('#welcome-card-container').fadeIn();
});

$('#result-card-dep-list-title').click(function() {
    $('#result-card-dep-list').slideToggle('slow');
});

$('#search-button').click(function() {
   submitLibraryRequest($('#search-box').val());
});

$('#try-now').click(function() {
   $('#search-box').val("com.google.code.gson:gson:2.4");
});

var loadingMessages = [
   "This may take a while... Grab a coffee, perhaps?",
   "Gradle and DX require some time to do their magic",
   ""
];


