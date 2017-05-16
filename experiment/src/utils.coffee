###*
# Helper function to see whether a value is defined.
#
# @param {string} name - An informative name for the value being checked
# @param val - The value to be checked
# @throws {Error} if the value is undefined
# @returns the value that was passed in
###

check = (name, val) ->
  if val is undefined
    throw new Error "#{name}is undefined"
  val

check_obj = (obj, keys) ->
  if not keys?
    keys = Object.keys(obj)
  for k in keys
    if obj[k] is undefined
      console.log 'Bad Object: ', obj
      throw new Error "#{k} is undefined"
  obj

assert = (val) ->
  if not val
    throw new Error 'Assertion Error'
  val


chunk = (arr, len) ->
  i = 0
  while i < arr.length
    arr[i...i+= len]

interleave = (arrs...) ->
  result = []
  lens = (a.length for a in arrs)
  min = Math.min(lens...)
  ratios = (l / min for l in lens)
  arrs = (arr.reverse() for arr in arrs)
  for i in [0...min]
    for j in [0...arrs.length]
      for k in [0...ratios[j]]
        result.push arrs[j].pop()
  result

deep_copy = (obj) -> JSON.parse(JSON.stringify(obj))

###*
# Function to check the window size, and determine whether it is
# large enough to fit the given experiment. If the window size is not
# large enough, it hides the experiment display and instead displays
# the error in the #window_error DOM element.#
###

check_window_size = (width, height, display) ->
  win_width = $(window).width()
  maxHeight = $(window).height()
  if $(window).width() < width or $(window).height() < height
    display.hide()
    $('#window_error').show()
  else
    $('#window_error').hide()
    display.show()

converter = new showdown.Converter()
md_to_html = (txt) -> converter.makeHtml(txt)

getTime = -> (new Date).getTime()