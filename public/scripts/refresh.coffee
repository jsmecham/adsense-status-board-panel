
var refreshInterval = 60 * 1000 // 60 Seconds

function refresh()
{
  var xhr = new XMLHttpRequest();
  xhr.onload = handleRefresh;
  xhr.open("get", window.location.href, true);
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  xhr.send();
}

function handleRefresh()
{
  document.querySelector(".widget").innerHTML = this.response
  setTimeout(refresh, refreshInterval)
};

setTimeout(refresh, refreshInterval)
