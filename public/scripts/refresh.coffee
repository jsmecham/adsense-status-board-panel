
refreshInterval = 60 * 1000 # 60 Seconds

refresh ->
  xhr = new XMLHttpRequest
  xhr.onload = handleRefresh
  xhr.open("get", window.location.href, true)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  xhr.send

handleRefresh ->
  document.querySelector(".widget").innerHTML = this.response

setInterval(refresh, refreshInterval)
