window.DraftBoardPage = class DraftBoardPage
  bind: ->
    if $.cookie('color-scheme')
      @setColorScheme($.cookie('color-scheme'))

    $(".draft-board .color-schemes a").each (i, a) =>
      link = $(a)
      link.click (e) =>
        colorScheme = link.data("color-scheme")
        @setColorScheme(colorScheme)
        $.cookie('color-scheme', colorScheme)

  setColorScheme: (colorScheme) ->
    $(".draft-board").removeClass("colors-colorblind-safe colors-red-green")
    $(".draft-board").addClass("colors-#{colorScheme}")
    $(".draft-board .color-schemes a.selected").removeClass("selected")
    $(".draft-board .color-schemes a[data-color-scheme=#{colorScheme}]").addClass("selected")


