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
   request(
         "POST",  
         "/api/request/" + libraryName, 
         function(response) {
            obj = JSON.parse(response);
            console.log("Successfully enqeueud job for " + obj["lib_name"]);
            $('#progress').css('visibility', 'visible')
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
            if(obj["status"] == "done") {
               console.log("Done");
               console.log(obj)
               $('#progress').css('visibility', 'hidden')
               document.getElementById('output').value = JSON.stringify(obj, null, "\t");
            }
            else {
               setTimeout(function() {
                  poll(libraryName);
               }, 4000);
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