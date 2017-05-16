###
experiment.coffee
Fred Callaway

# Cue balls experiment

###
# coffeelint: disable=max_line_length, indentation

DEBUG = yes


if DEBUG
  console.log """
  ==================================
  =========== DEBUG MODE ===========
  ==================================
  """
  condition = 0
  counterbalance = 0

if mode is "{{ mode }}"
  DEMO = true
  condition = 0
  counterbalance = 0

psiturk = new PsiTurk uniqueId, adServerLoc, mode

params = undefined
blocks = undefined

SKIP = jsPsych.endCurrentTimeline
skip_trials = (n) ->
  for _ in [0...n]
    jsPsych.finishTrial()

colorize = (c, txt) ->
  """<span style='color: #{c}'><b>#{txt}</b></span>"""

COMPLETED_INSTRUCTIONS = false
COLORS = [
  '#4C4FE1' # blue
  '#53BA42' # green
  '#E3B643' # yellow
]
COLOR_NAMES = [
  colorize COLORS[0],'Blue'
  colorize COLORS[1],'Green'
  colorize COLORS[2],'Yellow'
]
PLAYERS = [
  colorize COLORS[0], 'Player B'
  colorize COLORS[1], 'Player G'
  colorize COLORS[2], 'Player Y'
]

do ->  # big closure to prevent polluting global namespace

  #  ========================= #
  #  ========= SETUP ========= #
  #  ========================= #

  exp_data = do ->
    result = $.ajax
      dataType: 'json'
      url: "static/json/condition_#{condition}.json"
      async: false
    return result.responseJSON
    
  console.log 'exp_data', exp_data
  params = exp_data.params
  # params.show_feedback = true
  if DEBUG
    params.cue_within = true
    params.wall_cue = false
    params.color_cue = 'background'
    params.backstory = 'game'
    params.cue_counter = 1
    # params.block_size = 4
  

  psiturk.recordUnstructuredData 'params', params
  blocks = exp_data.blocks
  NUM_TRIALS = 0
  NUM_BLOCKS = undefined
  BLOCK_IDX = -1
  CUE_NAMES = undefined

  # Counterbalance player names and colors
  do ->
    i = params.cue_counter
    if DEBUG
      i = 3
    # GOOD_PLAYER = colorize(COLORS[i], 'Player ' + PLAYERS[i])
    # BAD_PLAYER = colorize(COLORS[(i+1) % 3], 'Player ' + PLAYERS[(i+1) % 3])
    # NEUTRAL_PLAYER = colorize(COLORS[(i+2) % 3], 'Player ' + PLAYERS[(i+2) % 3])
    params.cue_colors =
      hit: COLORS[i]
      neutral: COLORS[(i+1) % 3]
      miss: COLORS[(i+2) % 3]

    cue_color_names =
      hit: COLOR_NAMES[i]
      neutral: COLOR_NAMES[(i+1) % 3]
      miss: COLOR_NAMES[(i+2) % 3]
    
    if params.backstory
      CUE_NAMES = params.players =
        hit: PLAYERS[i]
        neutral: PLAYERS[(i+1) % 3]
        miss: PLAYERS[(i+2) % 3]
    else
      CUE_NAMES =
        hit: COLOR_NAMES[i]
        neutral: COLOR_NAMES[(i+1) % 3]
        miss: COLOR_NAMES[(i+2) % 3]


    console.log 'cue_color_names', cue_color_names


  if not DEMO
    $(window).resize -> check_window_size 900, 700, $('#jspsych-target')
    $(window).resize()


  #  ======================== #
  #  ========= TEXT ========= #
  #  ======================== #

  # These functions will be executed by the jspsych plugin that
  # they are passed to. String interpolation will use the values
  # of global variables defined in this file at the time the function
  # is called.

  text =
    debug: ->
      if DEBUG
        """\n\n
        
        `\n----------------------------------------`
        
        ## `EXPERIMENT ERROR`
        **IF YOU ARE SEEING THIS TEXT, THERE IS A MISTAKE IN
        THE EXPERIMENT.** Please email
        [fredcallaway@berkeley.edu](mailto:fredcallaway@berkeley.edu?subject=EXPERIMENT ERROR)
        immediately to warn him about his mistake! Please do not
        return the hit, but do not attempt to complete it either.
        It won't work. We will compensate you for your time!

        `----------------------------------------`
        """
      else ''

    # ![box](/static/images/box.png)
    instructions: -> md_to_html """
      # Instructions
      
      #{text.backstory()}

      On each trial, you will be asked to predict whether or not the ball will
      go in the hole. The ball can bounce off the outer walls any number of
      times, but once it hits the center wall, the round is over. If you think
      the ball will go in the hole, press **q** for *yes*. If you think the
      ball will miss the hole and hit the center wall, press **p** for *no*.

      Next up is a quiz to make sure you understand how the experiment works.
      Press the key corresponding to **yes** to continue.
      """
    
    # color_cue: ->
    #   one_color = (name, color) ->
    #     "**#{colorize(colors[color], name)}** uses a **#{colorize(colors[color], color)}** ball"
    #   return """
    #   #{one_color('Brian', 'blue')},
    #   #{one_color('Gary', 'green')}, and
    #   #{one_color('Yvonne', 'yellow')}.
    #   """

    # court_colors: ->
    #   one_color = (name, color) ->
    #     "**#{colorize(COLORS[color], name)}** plays on a **#{colorize(COLORS[color], color)}** court"
    #   return """
    #   #{one_color('Brian', 'blue')} and
    #   #{one_color('Yvonne', 'yellow')}.
    #   """

    color_cue: ->
      one_color = switch params.color_cue
        when 'ball'
          # (i) -> "**#{colorize(COLORS[i], 'Player '+PLAYERS[i])}** plays with a **#{colorize(COLORS[i], COLOR_NAMES[i])}** ball"
          (i) -> "#{PLAYERS[i]} plays with a #{COLOR_NAMES[i]} ball"
        when 'background'
          # (i) -> "**#{colorize(COLORS[i], 'Player '+PLAYERS[i])}** plays on a **#{colorize(COLORS[i], COLOR_NAMES[i])}** court"
          (i) -> "#{PLAYERS[i]} plays on a #{COLOR_NAMES[i]} court"
        else
          throw new Error('bad color_cue')

      
      return """
      #{one_color 0},
      #{one_color 1}, and
      #{one_color 2}
      """

    giveaway_long: ->
      if params.backstory is 'giveaway'
        """
        **Each player is playing a different version of the game.**

          - One of the players is trying to bounce the ball into the hole.
          - One is trying to avoid the hole.
          - One doesn't care whether or not the ball goes through the hole.

        At the beginning of every block, we will ask you which player you think
        is playing which game.
        """
      else ''
    giveaway_short: ->

      """
      One of them is trying to bounce the ball into the hole,
      one is trying to avoid the hole, and
      one doesn't care whether or not the ball goes through the hole.
      """
    backstory: ->

      if params.backstory in ['giveaway', 'game']
        """
        In this experiment, you will watch videos of three different people
        playing a game with a ball. #{text.color_cue()}

        The game is played in a box with five walls: four on the outside and
        one in the middle. The "center wall" in the middle has a hole in it, which
        changes size and location on every round. #{text.giveaway_long()}
        """

        # The goal of the game is to throw the ball so that it goes through this hole
        # *before it hits the center wall*. The player earns extra points if the
        # shot bounces off the other walls in the box, but your task is just to
        # determine whether each shot will go through the hole in the center
        # wall.
      else if params.backstory is 'lesson'
        """
        In this experiment, you will watch an imaginary person, Natalie, getting
        a lesson in playing a ball game.

        The game is played in a box with five walls: four on the outside and
        one in the middle. The wall in the middle has a hole in it. The goal
        of the game is to throw the ball so that it goes through this hole
        *before it hits the center wall*. The player earns extra points if the
        shot bounces off the other walls in the box, but your task is just to
        determine whether each shot will go through the hole in the center
        wall.
        """

      else
        """
        In this experiment, you will see a ball bouncing around in a box.

        The box has five walls: four on the outside and one in the middle. The
        wall in the middle has a hole in it. Your task is to determine whether the
        ball will go through the hole *before it hits the center wall*.
        """

    pre_training: -> md_to_html """
    # Nice job!

    You passed the quiz! Before the game starts, there will be a few
    practice rounds to help you learn how to perform the task.

    Press **space** to continue.
    """

    standard_header: -> md_to_html """
    # Well done!

    You've completed all the practice trials. Now, the actual experiment will
    begin, which will consist of **#{NUM_TRIALS} trials** divided into
    **#{NUM_BLOCKS} blocks**. Try to get as many correct as you can.

    #{text.game_on()}

    #{text.no_feedback()}

    Press **space** to continue.
    """

    game_on: ->
      switch params.backstory
        when 'game'
          "Remember, #{text.color_cue()}"
        when 'giveaway'
          "Remember, #{text.color_cue()}. #{text.giveaway_short()}"
        when 'lesson'
          """
          Because Natalie is taking a lesson, there will sometimes be a mark
          on the wall placed by her teacher.
        """
        else ''

    manipulation_check: ->
      template = (description) -> """
      Did you notice the #{description}?
      <br>
      Did you think it was relevant for determining whether the ball
      would go through the hole?
      """
      questions = []
      cues = [
        params.wall_cue
        params.color_cue == 'ball'
        params.color_cue == 'background'
      ]
      descriptions = [
        "red mark on the walls of the box"
        "ball changing color"
        "background changing color"
      ]
      for [cue_on, description] in _.zip(cues, descriptions)
        if cue_on
          questions.push template description
      return questions

    no_feedback: ->
      if params.show_feedback then '' else
        """
        Unlike in the training trials, **you will not see the path of the ball
        after you make a choice**. Some trials will be more difficult than others
        — just do your best!
        """

    bonus: (final=false) ->
      if params.bonus_rate
        lead = if final then "Your final bonus is " else "Your total bonus so far is "
        return lead + "<b>$#{calculate_bonus()}</b>"
      else
        return ""

    # cue_block: ->
    #   if params.game_backstory
    #     """
    #     **#{colorize(YELLOW, 'Yvonne')}** and **#{colorize(BLUE, 'Brian')}**
    #     are playing in this block.
    #     """

    # cueless_block: ->
    #   if params.game_backstory
    #     """
    #     **Natalie** is playing in this block.
    #     """

  #  ============================== #
  #  ========= EXPERIMENT ========= #
  #  ============================== #

  class Block
    constructor: (config) ->
      _.extend(this, config)
      @block = this  # allows trial to access its containing block for tracking state
      if @init?
        @init()

  class TextBlock extends Block
    type: 'text'
    cont_key: ['space']

  class BallBlock extends Block
    type: 'ball'
    cue_present: true
    players: null
    responses:
      q: 'yes'
      p: 'no'
    prompt: 'Will the ball go in the hole? (q=yes, p=no)'

    constructor: (config) ->
      @score = 0
      @trials_completed = 0
      _.extend(this, params)  # all trials get passed the default params
      super config

    num_trials: => @timeline.length
    bonus: => @score * params.bonus_rate

  # ========================= #
  # ========= Intro ========= #
  # ========================= #

  welcome = new TextBlock
    text: md_to_html """
    # Welcome

    Thanks for accepting our HIT and participating in our experiment!
    Before you begin, we need to test the connection to our database.

    Press **space** to continue.

    #{text.debug()}
    """

  save_error_page = new TextBlock
    text: -> md_to_html """
      # Error accessing database

      We are unable to access the experiment database. This could be due
      to an unreliable or slow Internet connection. Try refreshing this page.
      If you see this screen again, you unfortunately cannot complete the
      experiment. Please return the HIT so someone else may take your place.
      """
    cont_key: [192]  # grave accent (unlikely they'll hit this)

  save_error = new Block
    timeline: [save_error_page]
    loop_function: (data) ->
      return true

  check_database = new Block
    timeline: [save_error]
    conditional_function: ->
      console.log 'testing saveData'
      error = false
      psiturk.saveData
        error: ->
          console.log 'ERROR saving data.'
          error = true
        success: ->
          console.log 'Data saved to psiturk server.'
      return error

  save_data_block = new Block
    type: 'call-function'
    func: ->
      console.log 'Saving data.'
      psiturk.saveData()


  reload_error = new TextBlock
    text: -> md_to_html """
      # Error: refresh detected

      It appears that you have already completed the instructions
      and reloaded the page. This is against experiment protocol, so
      we cannot allow you to participate in the experiment. If you
      that there was a bug or mistake in the experiment, file a report
      at the following URL and we will compensate you for your time

      https://goo.gl/forms/BGpS1cs9rILVpxCS2
    """

  check_no_reload = new Block
    timeline: [reload_error]
    conditional_function: -> COMPLETED_INSTRUCTIONS

  save_success = new TextBlock
    text: -> md_to_html """
    # Success

    Great, we have a good connection to the database. Before you begin the
    experiment please copy down the following URL. If something goes wrong
    during the experiment, you can fill out that form to tell us what
    happened. We will compensate you for your time spent.

    https://goo.gl/forms/BGpS1cs9rILVpxCS2

    **Warning:** Do not close or refresh this window at any point during the
    experiment. Doing so will disqualify you from completing the experiment.

    Press **space** to continue.
    """

  initialize = new Block
    timeline: [welcome, check_database, save_success]


  instructions = new TextBlock
    text: text.instructions
    cont_key: ['q']

  quiz = new Block
    preamble: -> md_to_html """
      # Quiz
    """
    type: 'survey-multi-choice'
    questions: [
      """
        Which key should you press if you think the ball
        will bounce off the back wall and then fly through
        the hole in the center wall?
      """
      """
        Which key should you press if you think the ball will
        bounce off the center wall, then the back wall,
        and then fly through the hole in the center wall?
      """
      """
        What color is Player B's #{if params.color_cue is 'ball' then 'ball' else 'court'}?
      """
    ][...(if params.backstory in ['giveaway', 'game'] then 3 else 2)]
    options: [
      ['q (yes)', 'p (no)']
      ['q (yes)', 'p (no)']
      ['blue', 'yellow', 'green']
    ]
    required: [true, true, true]
    correct: ['q (yes)', 'p (no)', 'blue']
    on_mistake: (data) ->
      alert """You got at least one question wrong. We'll send you back to the
               instructions and then you can try again."""

  instruct_loop = new Block
    timeline: [instructions, quiz]
    loop_function: (data) ->
      for c in data[1].correct
        if not c
          return true  # try again
      psiturk.finishInstructions()
      psiturk.saveData()
      return false

  pre_training = new TextBlock
        text: text.pre_training

  training = new BallBlock
    show_feedback: true
    block_idx: BLOCK_IDX += 1
    wall_cue: false
    color_cue: false
    cue_colors: {}
    timeline: _.shuffle blocks.instruct
  
  # =============================== #
  # ========= Main Blocks ========= #
  # =============================== #

  previous_block_feedback = (last_block) ->
    if last_block.score?
      """

      In the previous block, you answered correctly on **#{last_block.score}**
      out of **#{last_block.num_trials()}** trials.
      """
    else
      ""

  if params.backstory
    class AskCueBlock extends Block
      type: 'survey-multi-choice'
      horizontal: true
      questions: [
        'Which player is trying to get the ball <b>into</b> the hole?'
        'Which player is trying to <b>avoid</b> the hole?'
        'How confident are you in your response to the previous two questions?'
      ]
      options: [
        PLAYERS
        PLAYERS
        ['not at all', 'a little', 'somewhat', 'very', 'certain']
      ]
      required: [true, true, true]
      correct: [CUE_NAMES.hit, CUE_NAMES.miss, 'certain']

  else
    class AskCueBlock extends Block
      type: 'survey-multi-choice'
      horizontal: true
      questions: [
        'The ball is <b>more</b> likely to go in when the background is...'
        'The ball is <b>less</b> likely to go in when the background is...'
        'How confident are you in your responses to the previous two questions?'
      ]
      options: [
        COLOR_NAMES
        COLOR_NAMES
        ['not at all', 'a little', 'somewhat', 'very', 'certain']
      ]
      required: [true, true, true]
      correct: [CUE_NAMES.hit, CUE_NAMES.miss, 'certain']



  block_header = (block_idx, last_block) ->
    header = "# Block #{block_idx + 1} of #{NUM_BLOCKS}"
    cont = '\n\nPress **space** to continue.'
    if params.backstory is 'giveaway' and block_idx isnt 0
      return new AskCueBlock
        preamble: -> md_to_html (header + (previous_block_feedback last_block))
    else
      return new TextBlock
        text: -> md_to_html (header + (previous_block_feedback last_block) + cont)


  mix_cue_trials = (trials) ->
    result = []
    n = trials.length
    cue = deep_copy trials
    no_cue = deep_copy trials
    # Shift trials to maximize distance between identical trials
    no_cue = no_cue[n/2..] .concat no_cue[...n/2]
    while cue.length
      result.push cue.pop()
      nc = no_cue.pop()
      nc.cue_present = false
      result.push nc
    return result

  mixed_cue = -> new Block
    timeline: do ->
      easy = mix_cue_trials (_.shuffle blocks.easy)
      medium = mix_cue_trials (_.shuffle blocks.standard)
      hard = mix_cue_trials (_.shuffle blocks.hard)
      controls = _.shuffle blocks.control

      bs = 12
      breakdowns = [
        [4, 0, 0]
        [3, 1, 0]
        [2, 2, 0]
        [1, 3, 0]
        [0, 4, 0]
        [0, 3, 1]
        [0, 2, 2]
        [0, 1, 3]
        [0, 0, 4]
      ]
      mult = bs / 4
      m_blocks = for [e, s, h] in breakdowns
        ctrl = if controls.length then [controls.pop()] else []
        _.shuffle ((easy   .splice 0, e * mult) .concat \
                   (medium .splice 0, s * mult) .concat \
                   (hard   .splice 0, h * mult) .concat ctrl)

      # console.log 'TIMELINE'
      # for b in m_blocks
        # console.log b.length
        # console.log '----------------------'
        # for t in b
          # console.log "#{t.kind}  #{t.color_cue}  #{t.layout}"
          
      NUM_BLOCKS = m_blocks.length + 1  # includes critical
      timeline = []
      # if DEBUG
        # timeline.push new BallBlock
          # timeline: m_blocks[4]
      timeline.push new TextBlock
        text: text.standard_header

      for trials in m_blocks
        console.log 'last', _.last timeline
        timeline.push block_header(BLOCK_IDX, (_.last timeline))
        timeline.push new BallBlock
          timeline: trials
          block_idx: BLOCK_IDX += 1
        NUM_TRIALS += trials.length

      return timeline


  all_cue = -> new Block
    timeline: do ->
      easy = chunk (_.shuffle blocks.easy), 3
      medium = chunk (_.shuffle blocks.standard), 3
      hard = chunk (_.shuffle blocks.hard), 3
      controls = _.shuffle blocks.control

      s_blocks = [
        _.shuffle (_.flatten ((easy.splice 0, 4)                              .concat [controls.pop()]))
        _.shuffle (_.flatten ((easy.splice 0, 3) .concat (medium.splice 0, 1) .concat [controls.pop()]))
        _.shuffle (_.flatten ((easy.splice 0, 2) .concat (medium.splice 0, 2) .concat [controls.pop()]))
        _.shuffle (_.flatten ((easy.splice 0, 1) .concat (medium.splice 0, 3) .concat [controls.pop()]))
        _.shuffle (_.flatten (                           (medium.splice 0, 4)                         ))
        _.shuffle (_.flatten ((hard.splice 0, 1) .concat (medium.splice 0, 3) .concat [controls.pop()]))
        _.shuffle (_.flatten ((hard.splice 0, 2) .concat (medium.splice 0, 2) .concat [controls.pop()]))
        _.shuffle (_.flatten ((hard.splice 0, 3) .concat (medium.splice 0, 1) .concat [controls.pop()]))
        _.shuffle (_.flatten ((hard.splice 0, 4)                              .concat [controls.pop()]))
      ]

      NUM_BLOCKS = s_blocks.length + 1  # includes critical

      timeline = []

      timeline.push new TextBlock
        text: text.standard_header

      for trials in s_blocks
        timeline.push block_header(BLOCK_IDX, (_.last timeline))
        timeline.push new BallBlock
          timeline: trials
          block_idx: BLOCK_IDX += 1
        NUM_TRIALS += trials.length

      return timeline

  standard = if params.cue_within then mixed_cue() else all_cue()

  debug = new BallBlock
    timeline: blocks.standard


  # ================================ #
  # ========= Final Blocks ========= #
  # ================================ #
  

  pre_critical = do ->
    no_feedback = if params.show_feedback then """
      For the last few trials, you won't see any feedback.
      Just do your best!
      """
    else ""
    cont = '\n\nPress **space** to continue.'
    header = "# Block #{NUM_BLOCKS} of #{NUM_BLOCKS}"

    if params.backstory is 'giveaway'
      return new AskCueBlock
        preamble: -> md_to_html """
        #{header}

        #{previous_block_feedback (_.last standard.timeline)}

        #{no_feedback}
        """
    else
      return new TextBlock
        text: -> md_to_html """
        #{header}

        #{previous_block_feedback (_.last standard.timeline)}

        #{no_feedback}

        #{cont}
        """

  critical = new BallBlock
    block_idx: BLOCK_IDX +=1
    show_feedback: false
    timeline: do ->
      timeline = []
      crit = blocks.critical
      filler = _.shuffle(blocks.filler)
      for i in [0...crit.length]
        timeline.push crit[i]
        if (crit.length / 2) <= i < (crit.length - 1)
          # add filler trials between critical trials with bogus cues
          timeline.push filler.pop()
          timeline.push filler.pop()

      NUM_TRIALS += timeline.length
      return timeline

  final_ask_cue = new AskCueBlock
    preamble: ->
      md_to_html """
      # All blocks completed

      #{previous_block_feedback critical}
      """

  ask_cue = new AskCueBlock
    preamble: ->
      md_to_html """
      # Survey

      """

  final_feedback = new TextBlock
    text: ->
      md_to_html """
      # All blocks completed

      #{previous_block_feedback critical}

      Press **space** to continue.
      """

  survey = new Block
    type: 'survey-text'
    preamble: md_to_html("""
      # Survey

      Thanks for participating in our experiment! Please take a few moments to
      answer the following questions. You can keep it short and sweet.
      """)
    questions: [
      "How did you decide whether or not the ball would go in the hole?"
      "Did you change your strategy at any point during the experiment?"
      "Anything else you'd like to tell us?"
    ]
    rows: 4
    columns: Array(4).fill(60)

  final = new Block
    timeline: do ->
      if params.backstory is 'giveaway'
        [final_ask_cue, survey]
      else
        [final_feedback, survey, ask_cue]



  #  ================================================ #
  #  ========= START THE EXPERIMENT ================= #
  #  ================================================ #

  if DEBUG
    experiment_timeline = [
      debug
      initialize
      instruct_loop
      pre_training
      training
      save_data_block
      standard
      pre_critical
      critical
      final
    ]
  else
    experiment_timeline = [
      initialize
      instruct_loop
      pre_training
      training
      save_data_block
      standard
      pre_critical
      critical
      final
    ]

  try
    jsPsych.init
      display_element: $('#jspsych-target')
      timeline: experiment_timeline
      # show_progress_bar: true
      on_finish: ->
        if DEBUG
          jsPsych.data.displayData()
        else
          psiturk.recordUnstructuredData 'final_bonus', 0
          save_data()

      on_data_update: (data) ->
        console.log 'data', data
        psiturk.recordTrialData data
  catch


  

# ====================================== #
# ========= END THE EXPERIMENT ========= #
# ====================================== #

calculate_bonus = -> 0 # standard.score * params.bonus_rate

REPROMPT = null
save_data = ->
  psiturk.saveData
    success: ->
      console.log 'Data saved to psiturk server.'
      if REPROMPT?
        window.clearInterval REPROMPT
      psiturk.completeHIT()
    error: -> prompt_resubmit

prompt_resubmit = ->
  $('#jspsych-target').html """
    <h1>Oops!</h1>
    <p>
    Something went wrong submitting your HIT.
    This might happen if you lose your INTERNET connection.
    Press the button to resubmit.
    <p>
    If you continue to have problems, please fill out the following form
    and we will pay you with a compensation HIT.
    <p>
    https://goo.gl/forms/BGpS1cs9rILVpxCS2
    <p>
    <button id="resubmit">Resubmit</button>
  """
  $('#resubmit').click ->
    $('#jspsych-target').html 'Trying to resubmit...'
    REPROMPT = window.setTimeout(prompt_resubmit, 10000)
    save_data()



