
refreshInterval = 60 * 5 * 1000 # 5 Minutes

refresh = ->
  path = window.location.pathname
  queryString = window.location.search.substring(1)
  queryString = queryString.replace("/", "")

  $.get path, queryString, (response) ->
    $(".widget").html(response)

setInterval(refresh, refreshInterval)
