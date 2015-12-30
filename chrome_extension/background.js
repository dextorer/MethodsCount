/**
 * MethodsCount Chrome Extension
 */

function getSelection(info) {
  var libFQN = info.selectionText;
  var targetURL = "http://methodscount.com/?lib=" + encodeURI(libFQN);
  chrome.tabs.create({url: targetURL});
}

// Create one test item for each context type.
chrome.contextMenus.create({"title": "Check on MethodsCount.com",
                            "contexts": ["selection"],
                            "onclick": getSelection});

/*document.addEventListener('selectionchange', function() {
    console.log("dioboia");
});*/