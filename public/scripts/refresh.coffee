
refreshInterval = 60 * 5 * 1000 # 5 Minutes

handleRefresh = ->
  document.querySelector(".widget").innerHTML = this.response

refresh = ->
  xhr = new XMLHttpRequest()
  xhr.onload = handleRefresh
  xhr.open("get", window.location.href, true)
  xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
  xhr.send()

setInterval(refresh, refreshInterval)
