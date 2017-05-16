###
jspsych-template.coffee
Fred Callaway

Template for jspsych plugins

###
# coffeelint: disable=max_line_length, indentation

debug_log = (args...) ->

TRIALS_COMPLETED = 0
SCORE = 0

debug_info = (e, trial_config) ->
    msg = e.name
    if e.message
      msg += ' | MESSAGE: ' + e.message
  
  # try
    return """
    ```
    ----------------------------------------
    PARAMS:
    #{JSON.stringify params}

    TRIAL_CONFIG:
    #{JSON.stringify trial_config}

    ERROR MESSAGE:
    #{JSON.stringify msg}
    ----------------------------------------
    ```
    """
  # catch
  #   return 'ERROR CREATING DEBUG INFO'

handle_error = (e, trial_config, display) ->

  delete trial_config.block
  delete trial_config.constructor
  psiturk.recordTrialData trial_config

  DEBUG_INFO = debug_info(e, trial_config)
  console.log DEBUG_INFO

  psiturk.recordUnstructuredData 'DEBUG_INFO', DEBUG_INFO

  display.html md_to_html """
  # Experiment Error

  The experiment has encountered an error. Unfortunately, you cannot
  continue the experiment. We will attempt to complete the HIT early.
  In case we cannot successfully complete the HIT, please copy down the
  following URL. If you cannot submit the HIT, fill out the form at that
  URL and we will pay you through a compensation HIT. We're sorry (and
  frankly quite embarased) about this inconvenience. Thank you for your time!
  
  https://goo.gl/forms/BGpS1cs9rILVpxCS2
  
  Please additionally include the following debugging information if you need
  to fill out that form:

  #{debug_info(e, trial_config)}

  """
  $('<button>')
  .addClass('btn btn-primary btn-lg')
  .text('Submit HIT')
  .click (->
    display.empty()
    save_data())
  .appendTo display

class BallTrial
  constructor: (config, @display) ->
    # This syntax assigns all the listed attributes to the BallTrial object
    # from the identically-named attributes in config. We assign all these
    # to `params` only so that we can log them.
    params = {
      @hole
      @layout
      @condition
      @color_cue
      @wall_cue
      @cue_present
      @kind
      @prompt
      @responses
      @block
      @num_trials
      @cue_colors
      @players
      @block_idx=-1
      @right_message=null
      @good_cue=true
      @show_feedback=true
      @draw_trajectory=true
      @wall_color = 'black'
    } = config
    @data = {@hole, @layout, @condition, @color_cue, @wall_cue, @cue_present, @kind,
             @good_cue, @show_feedback, @draw_trajectory, @block_idx,}

    console.log 'BallTrial params', params
    if not @good_cue
      console.log 'BAD CUE'
    check_obj(this)

    
    if @message?.length
      # Still be there from previous trial
      @progress_counter = $('#progress_counter')
      @prompt = $('#prompt').css('color', 'black')
      @score_counter = $('#score_counter')
      @canvas = $('#canvas')
    else
      @progress_counter = $('<div>',
        id: 'ball_progress_counter',
        html: '&nbsp').appendTo(@display)

      @message = $('<div>',
        id: 'ball_message'
        html: @prompt or '&nbsp').appendTo(@display)

      @score_counter = $('<div>',
        id: 'ball_score_counter',
        html: '&nbsp').appendTo(@display)
      
      @canvas = $('<canvas>',
         id: 'canvas').appendTo(@display)

      @update_counters()


  init: =>

    url = "static/json/#{@hole}.json"

    n_tries = 3
    load_stim = =>
      $.ajax
        dataType: 'json'
        url: url
        async: false
        success: @create_stim
        error: ->
          console.log "error loading stim #{url}"
          if n_tries
            n_tries -= 1
            load_stim()
          else
            throw new Error("Error loading #{url}")

    do load_stim

  create_stim: (stim_config) =>
    debug_log 'create_stim'

    stim_config = _.extend stim_config, {
      @draw_trajectory
      @color_cue
      @cue_colors
      @wall_cue
      @cue_present
      @wall_color
      @good_cue}

    @stim = new HoleStimulus(stim_config)
    @stim.init @canvas
    @stim.loadLayout @layout, 'stimulus'
    @stim.drawOnce()  # draw the scene

    player = null
    if @color_cue
      cue_says_hit = @stim.metadata.goes_in == @good_cue
      if @players
        if @cue_present
          player = if cue_says_hit then @players.hit else @players.miss
        else
          player = @players.neutral

    if player
      @score_counter.html "Player: #{player}"


    else
      @score_counter.html "&nbsp"

    @message.html 'Press space to start the trial'
    @keyboard_listener = jsPsych.pluginAPI.getKeyboardResponse
      valid_responses: ['space']
      rt_method: 'date'
      persist: false
      allow_held_key: false
      callback_function: (info) => @start()
    
  start: =>
    @stim.startDrawing()
    @stim.animate @query_response

  query_response: =>
    start = Date.now()
    @stim.stopDrawing()
    @message.html @prompt

    # start the response listener
    @keyboard_listener = jsPsych.pluginAPI.getKeyboardResponse
      valid_responses: Object.keys(@responses)
      rt_method: 'date'
      persist: false
      allow_held_key: false
      callback_function: (info) => @after_response info

  after_response: (info) =>
    TRIALS_COMPLETED += 1
    response = @responses[String.fromCharCode(info.key).toLowerCase()]
    debug_log 'after', this
    correct = @stim.metadata.goes_in and response == 'yes' or
                 !@stim.metadata.goes_in and response == 'no'
    if correct
      @block.score += 1
      console.log "CORRECT #{@block.score}}"
      SCORE += 1

    _.extend @data,
        response: response
        rt: info.rt
        num_bounces: @stim.metadata.num_bounces
        correct: correct
        score: @block.score
        goes_in: @stim.metadata.goes_in
        trial: @block.trials_completed += 1
        trials_completed: TRIALS_COMPLETED

    @update_counters()

    if DEBUG
      console.log if @data.correct then '✓' else '✘'
    if @show_feedback
      if @data.correct
        @message.css('color', '#00c').text 'Correct!'
      else
        @message.css('color', 'red').text 'Incorrect.'
      @stim.loadLayout @layout, 'feedback'


    finish_feedback = =>
      # @stim.clearLayout()
      # @prompt.text ''
      @end_trial()

    if @show_feedback
      # @showPrompt config.prompt
      @stim.startDrawing()
      @stim.animate finish_feedback
    else
      finish_feedback()
    return

  end_trial: =>
    debug_log 'end', this
    @stim.clearLayout()
    @message.html '&nbsp'
    jsPsych.finishTrial @data
    return

  update_counters: =>
    @progress_counter.html "Progress: #{@block.trials_completed}/#{@num_trials}"
    # if @show_feedback
    #   @score_counter.html "Score: #{SCORE}/#{TRIALS_COMPLETED}"
    # else
    #   @score_counter.html '&nbsp'

jsPsych.plugins['ball'] = do ->

  plugin = {}
  plugin.trial = (display_element, trial_config) ->
    display_element.empty()
    try
      trial_config = jsPsych.pluginAPI.evaluateFunctionParameters(trial_config)

      trial = new BallTrial(trial_config, display_element)
      window.trial = trial
      trial.init()
    catch e
      handle_error e, trial_config, display_element

  plugin