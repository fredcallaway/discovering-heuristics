---
title: Discovering simple heuristics from mental simulation
author:
    - name: Frederick Callaway
      email: fredcallaway@berkeley.edu
    - name: Jessica B. Hamrick
      email: jhamrick@berkeley.edu
    - name: Thomas L. Griffiths
      email: tom_griffiths@berkeley.edu
affiliation: Department of Psychology; University of California, Berkeley; Berkeley, CA, USA
date: \today
abstract: |
    In the history of cognitive science, there have been two competing philosophies regarding how people reason about the world.
    In one, people rely on rich, generative models to make predictions about a wide range of scenarios; while in the other, people have a large "bag of tricks", or heuristics, that they have accumulated over time.
    In this paper, we suggest that rather than being in opposition to one another, these two ideas complement each other.
    We argue that people's capacity for mental simulation may support their ability to learn new cue-based heuristics, and demonstrate this phenomenon in two experiments.
    However, our results also indicate that participants are far less likely to learn a heuristic when there is no logical or explicitly conveyed relationship between the cue and the relevant outcome.
    Furthermore, simulation---while a potentially useful tool---is no substitute for real world experience.
keywords: mental simulation, heuristics, physical reasoning
bibliography: bibliography.bib
---

# Introduction

<!-- What is the problem? -->
The world is a complex place, yet people are able to navigate it effortlessly.
How is the mind able to do so much?
One answer is that the mind builds rich, generative models of the world \citep{tenenbaum11}, which it then uses to ``mentally simulate'' potential futures and make inferences about objects and scenes.
Indeed, there is a vast literature on how mental simulation underlies our core reasoning and problem solving abilities, including spatial reasoning \citep{Shepard1971,Hegarty2004}, physical scene understanding \citep{Smith2013,battaglia13}, counterfactual reasoning \citep{Gerstenberg2014}, and language comprehension \citep{Matlock2004,Bergen2007}.
Yet, despite the power and flexibility of mental simulation, there is a cost associated with its use: running simulations and evaluating their results takes time and resources.
An alternative is to rely instead on simple heuristics that usually point to a good answer \citep{gigerenzer99}.
But, where do such heuristics come from in the first place?

<!-- What has been done, and what is the gap? -->
Previous research has explored the notion of ``learning by thinking'' \citep{Lombrozoinpress}, demonstrating that people have the ability to learn new knowledge or re-represent old knowledge through internal processes such as simulation.
For example, \citet{hamrick16} showed how people can use their mental simulations to learn about unobservable properties of the world such as the mass of objects; \citet{Khemlani2013} illustrated how mental simulations can give rise to algorithmic problem-solving procedures; and \citet{Schwartz1996} demonstrated that people can learn simple rules about a physical system on the basis of mental simulation.
Thus, it is clear that people _can_ acquire new knowledge or heuristics from mental simulation; but, under what circumstances will they do so?

<!-- What do we propose? -->
In this paper, we propose that generative models can bootstrap the discovery of heuristics for novel tasks, but that people's priors strongly influence how likely they are to discover such heuristics.
We pose three key questions regarding this claim.
First, to what extent are people able to learn new information from their mental simulations?
Second, to what extent do people use this information to construct new heuristics?
And third, is mental simulation as reliable as real-world experience in learning such heuristics?

To determine how people learn heuristics from mental simulation, we designed and ran two experiments adapted from \citet{hamrick15} in which we asked people to predict whether or not a ball would go through a hole based on its initial trajectory.
Importantly, we also manipulated an environmental cue---the color of the box containing the ball---that perfectly predicted the correct response.
In the first experiment, we primed participants with the knowledge that a simple rule  existed (but did not tell them the rule itself); in the second, we primed them with either weak expectations or no expectations, and then allowed them to do the task and discover the rule independently.
Our results show that people are capable of crystallizing new rules solely on the basis of their mental simulations, though they are significantly less likely to do so if they are not already entertaining the hypothesis that a rule exists.
Moreover, we show that mental simulation, while an avenue for learning such rules, is no substitute for real world experience.

# Experiment 1: Learning about known cues

\begin{figure*}[t]
\begin{center}
\includegraphics[width=0.9\textwidth]{figs/task/task.png}
\caption{Sample experimental stimuli. Participants are asked to predict whether a ball will go through a hole based on its initial trajectory.
Left: The initial prompt stimulus for a trial with an \emph{honest} cue.
The blue background indicates that the ball will not go through the hole, a \emph{miss}.
Note the trail indicating the path the ball took in the immediately preceding animation.
Center: The final frame of a feedback animation (only provided in half of conditions), also for an honest cue.
The yellow background indicates that the ball goes through the hole, a \emph{hit}.
Right: A critical trial with a \emph{deceitful} cue.
Although the blue background would normally indicate that the ball misses the hole, in this case, the ball actually goes into the hole (as indicated by the red dotted line added to the figure for clarity).}
\label{fig:task}
\end{center}
\end{figure*}

In our first experiment, we asked to what extent people are able to learn heuristics from mental simulation when they are aware such a heuristic might exist.
We used a task adapted from \citet{hamrick15}, in which participants made a series of binary decisions predicting whether or not a ball would go through a hole (see Figure \ref{fig:task}).
The key modification was to provide participants with additional information in the form of associative cues (see __Stimuli__) that perfectly predicted the correct response and that did not require mental simulation.

## Methods

### Participants

We recruited `EXP1_N_PARTICIPANT` participants on Amazon’s Mechanical Turk using the psiTurk experimental framework \citep{gureckis15}.
Participants were treated in accordance with UC Berkeley IRB standards and were paid $1.50 for roughly 14 minutes of work.
We excluded `EXP2_N_FORMAT` participants who did not finish the experiment and `EXP2_N_CAUGHT` participants who answered incorrectly on more than one catch trial.
This left a total of `EXP2_N_REMAIN` participants in our analysis.

### Design

We used a $3 \times 3 \times 2$ mixed design.
We manipulated two within-subject variables, \textsc{cue} and \textsc{difficulty}.
\textsc{cue} could take on three values: *honest* (the cue perfectly predicts the correct response), *neutral* (the cue contains no information), and *deceitful* (the cue predicts the incorrect response).
\textsc{difficulty} could take on three values as well: *easy*, *medium*, and *hard* (see __Stimuli__).
We manipulated one between-subjects variable, \textsc{feedback}, which determined whether people were allowed to see the full path of the ball (and thus the correct answer) after making a judgment.

### Stimuli

The stimuli were animations of a ball with a radius of 10px moving in a box with dimensions $900\times 650$px.
The ball had a velocity of 400px/s, and as it moved, it traced a gray line (see Figure \ref{fig:task}).
The initial stimulus presentation consisted of the ball moving for 0.2 seconds, after which the ball would freeze, remaining on screen along with its trace.
The feedback animation picked up where the initial stimulus presentation left off, and showed the ball bouncing some number of times and then either (1) passing through the hole (a _hit_); or (2) bouncing off the central wall (a _miss_).

The properties of a stimulus depended on the trial's difficulty.
_Easy_ stimuli had one bounce, a path length of 560px, and a hole size of 300px.
_Medium_ stimuli had one or two bounces, a path length of 880px, and a hole size of 200px.
Finally, _hard_ stimuli had two bounces, a path length of 1280px, and a hole size of 100px.

The color of the background could be blue, green, or yellow depending on both the correct response and the value of \textsc{cue} for that trial.
For each participant, the three colors were mapped to _hit_, _miss_, and _neutral_ (this mapping was counterbalanced).
Thus, on an *honest* trial, the background would take the _hit_ color if the ball would go through the hole, and the _miss_ color, otherwise.
This mapping was reversed for *deceitful* trials.
Finally, on a *neutral* trial, the background was always the _neutral_ color.

We had four groups of stimuli: *instruction*, *experimental*, *catch*, and *critical*.
The eight instruction trials consisted of eight unique animations (half *hit* and half *miss*).
There were `EXP1_N_STIM` unique experimental stimuli, each shown once with an honest cue and once with a neutral cue.
Of the resulting `EXP1_N_TRIAL` trials, `EXP1_N_HIT` were *hit* trials and `EXP1_N_MISS` were *miss* trials. This small difference is a result of the incremental difficulty structure (see **Procedure**) and the constraint that there be no correlation between the presence of the cue and difficulty or hit/miss.
Eight catch trials (half *hit* and half *miss*) were designed to have an obvious answer, and were used to assess participant attention.
Eight critical trials were constructed with the same parameters as hard trials.
Half of these trials were displayed with deceitful cues, as described in __Procedure__.

### Procedure

\begin{figure*}[t!]
\begin{center}
    \begin{subfigure}[t]{0.417\textwidth}
        \includegraphics[width=\textwidth]{figs/1/critical_correct.pdf}
    \end{subfigure}%
    \begin{subfigure}[t]{0.583\textwidth}
        \includegraphics[width=\textwidth]{figs/1/difficulty_correct.pdf}
    \end{subfigure}
    \caption{Accuracy on critical (left) and standard (right) trials in Experiment 1. Left: Critical trials were displayed either with an honest cue or with a deceitful cue. Participants performed well when the cue was accurate, but quite poorly when it was inaccurate, suggesting that they were relying on the cue rather than using simulation. Right: Participants tended to respond more accurately on honest-cue trials than on neutral-cue trials. Error bars denote 95\% confidence intervals by bootstrapping.}
    \label{fig:exp1}
\end{center}
\end{figure*}

Participants were first given instructions in which the task was described.
We specifically informed participants that they would observe three people playing a game on three different courts: "Player B" was playing on a blue court, "Player G" was playing on a green court, and "Player Y" was playing on a yellow court.

We additionally told participants that one of the players was playing a game in which they were trying to get the ball in the hole, one was playing a game in which they were trying to avoid the hole, and one was playing a game in which they didn't care whether or not it went in.
This backstory was designed to increase participants' subjective prior probability of and attention to the hypothesis that the background color was predictive of the correct response.
Crucially, however, the backstory only motivated the existence of such a predictive relationship; it does not indicate its direction.

On each trial, participants were shown the scene, including the initial position of the ball and the location of the hole.
Participants pressed 'space' to begin the trial, after which an animation of the initial stimulus began.
Participants were then asked, “will the ball go in the hole?”, and were instructed to press ‘q’ if they thought it would and ‘p’ otherwise.
Participants in the *feedback* condition then saw "Correct!" or "Incorrect" as well as an animation showing the full remaining trajectory of the ball.

Participants were first given the instruction trials to familiarize them with the procedure.
These trials had feedback regardless of condition.
Participants then made judgments on the `EXP1_N_TRIAL` standard trials, evenly divided into nine blocks (with an additional single catch trial in each of the first eight blocks).
The blocks steadily increased in difficulty, beginning with all easy trials, then 25% easy, 75% medium, and so on until the ninth block which was 100% hard trials.
In total, there were `EXP1_N_EASY` easy, `EXP1_N_MEDIUM` medium, and `EXP1_N_HARD` hard trials.
At the beginning of each standard block (except the first), all participants saw their accuracy from the preceding block.
Additionally, they answered three multiple choice questions, which we will refer to as the _cue quiz_: "Which player is trying to get the ball **into** the hole?", "Which player is trying to **avoid** the hole?", and "How confident are you in your response to the previous two questions?".

The final (tenth) block of trials was designed to be especially discriminative of cue-learning.
The first four trials were drawn from the set of eight critical stimuli, and were displayed with honest cues.
The remaining four critical stimuli were displayed with deceitful cues, (i.e. the cue predicted the incorrect answer).
Participants who were using the cue, would be likely to answer incorrectly on such trials.
To prevent participants from noticing the change in reliability of the cue, feedback was not shown in the final block, regardless of condition.
Additionally, two filler trials with honest cues were placed between each *deceitful* trial.
These trials were excluded from analysis.
The order (and hence the cue-reliability) of the eight critical stimuli was counterbalanced.

<!-- After completing all trials, participants filled out a survey asking what their strategy was, and whether they ever changed their strategy.-->

## Results

<!-- We conducted our analyses in Python. All data and analysis code can be viewed at \TODO{OSF URL}. -->

### Hypotheses

Based on our experimental design, we hypothesized the following:
(1) Participants in both the *no feedback* and *feedback* conditions will learn the cue, as determined by their responses to the cue quizzes and based on their responses on the critical trials.
(2) Participants in both the *no feedback* and *feedback* conditions will use their knowledge of the cue to respond more accurately in the task.
(3) Participants in the *feedback* condition will be more likely to learn and use the cue than participants in the *no feedback* condition.

### Cue quizzes

To analyze whether people explicitly picked up on the cue, we analyzed the last "cue quiz" before the critical trials.
We conducted three one-tailed proportion tests comparing the proportion of participants in each condition who answered both questions correctly on the quiz, with a chance probability of $\frac{1}{6}$.
We found that `EXP1_QUIZ_NOFB_P`% of participants in the *no feedback* condition (`EXP1_QUIZ_CHI_NOFB_NULL`) and `EXP1_QUIZ_FB_P`% of participants in the *feedback* condition (`EXP1_QUIZ_CHI_FB_NULL`) correctly identified the cue.
These results suggest that participants were indeed able to use their mental simulations to learn about the cue, confirming our first hypothesis.

### Critical trials

According to our first hypothesis, we anticipated that participants who learned and used the cue strategy would fail on the four critical trials in which the cue was misinformative.
We constructed a logistic regression model over accuracy on critical trials with factors for \textsc{feedback} and \textsc{cue}.
The results, displayed in Figure \ref{fig:exp1}, suggest that people in both the *feedback*  and *no feedback* conditions were more likely to answer incorrectly on *deceitful* trials than on *honest* trials.
Specifically, we found a significant main effect of \textsc{cue}, with participants responding more accurately on *honest* trials than on _deceitful_ trials (`EXP1_CRIT_ANOVA_GOOD_CUE`).
We also found a significant main effect of \textsc{feedback} (`EXP1_CRIT_ANOVA_FEEDBACK`), as well as an interaction between \textsc{feedback} and \textsc{cue} (`EXP1_CRIT_ANOVA_FEEDBACK_GOOD_CUE`).

We performed planned contrasts (adjusted for multiple comparisons) within each feedback condition, and found that in both conditions people were more likely to answer incorrectly on *deceitful* trials than on *honest* trials, though this difference was only marginally significant in the *no feedback* condition (for *feedback*, `EXP1_CRIT_FB_ZTEST`; for *no feedback*, `EXP1_CRIT_NOFB_ZTEST`; where LLR is the log likelihood ratio).
This difference partially supports hypotheses 1 and 2: that participants learned the cue and were able to apply that knowledge when performing the task.

### Standard trials

We also looked at the accuracy across trials during the main part of the experiment.
We constructed a logistic regression model over accuracy with factors for \textsc{feedback}, \textsc{difficulty}, and \textsc{cue}.
The results are shown in Figure \ref{fig:exp1}.
We found a main effect of difficulty (`EXP1_ACC_ANOVA_DIFFICULTY`), as well as a three-way interaction between \textsc{feedback}, \textsc{difficulty}, and \textsc{cue} (`EXP1_ACC_ANOVA_CUE_FEEDBACK_DIFFICULTY`).

Using planned contrasts (adjusted for multiple comparisons), we investigated differences in accuracy within feedback conditions and cue types.
We found that, overall, people were more accurate on *honest* trials when they had feedback than when they did not have feedback (`EXP1_ACC_CUE_HONEST`), supporting our third hypothesis that real data is more reliable than simulated data.
We did not detect a difference between feedback conditions on *neutral* trials, however, indicating that feedback did not play a major role in people's accuracy when using simulation (`EXP1_ACC_CUE_NEUTRAL`).
We also found that people were more accurate when the honest cue was present than when the neutral cue was present, both in the *feedback* condition (`EXP1_ACC__FB`) and the *no feedback* condition (`EXP1_ACC__NOFB`).

## Modeling individual differences in cue learning

While the group-level effects in the previous sections confirmed our first and third hypotheses, we wanted to additionally investigate the individual behavior of participants who learned the cue. To this effect, we constructed a simple Markov model that allowed us to identify who actually used the cue and who did not.

### Model

\begin{figure}[t!]
\begin{center}
\includegraphics[width=0.45\textwidth]{figs/1/learners.pdf}
\caption{Example cue learners. Each subplot shows a different participant in the \emph{no feedback} condition of Experiment 1 who was identified as learning the cue by our model.
The blue lines indicate average accuracy on each block when using the honest cue, while the gray lines correspond to the neutral cue.
The vertical red lines indicate the trial, $C$, when our model inferred they switched from using simulation to using the cue.
The horizontal dashed lines indicate chance performance.
The title of each subplot displays the log likelihood ratio of the \emph{change} model to the \emph{no change} model, as well as the trial when they changed strategies.}
\label{fig:got-it}
\end{center}
\end{figure}

For each participant, we defined a Markov model with observed states $J_t$ representing the participants' judgment on trial $t$.
For each strategy, we defined a probability of answering correctly.
For the simulation probability, we fit $p_\mathrm{sim}^{(\mathrm{easy})}$, $p_\mathrm{sim}^{(\mathrm{med})}$, and $p_\mathrm{sim}^{(\mathrm{hard})}$ empirically based on the participant's average accuracy on trials without the cue for each level of difficulty.
For the cue probability, we set $p_\mathrm{cue}=0.95$ to reflect a high probability of answering correctly, but not perfectly.
Finally, we introduced a variable $C\in\{1, \ldots{}, T\}$ which indicated the "change point" at which participants switched from using simulation to using the cue heuristic.

The probability of a participant's judgment was then:
$$
p(J_t=1\ \vert\ C)=\left\{\begin{array}{ll}
p_\mathrm{sim}^{(d_t)} & t \leq C, \\
p_\mathrm{cue} & t > C,
\end{array}\right.
$$
where $d_t$ is difficulty of trial $t$.
So, the probability of all responses was $\max_C p(\mathbf{J}_{1:T}\ \vert\ C)=\max_C\prod_{t=1}^T p(J_t\ \vert\ C)$, which we will refer to as the _change_ model.
We fit $C$ in the change model to each participant separately.

We additionally computed the likelihood of participants' responses under a _no change_ model, in which we computed $p(\mathbf{J}_{1:T}\ \vert\ C=\infty)=\prod_{t=1}^T p(J_t\ \vert\ C=\infty)$, where the infinite change point $C$ indicates that the participant used the simulation strategy throughout the whole experiment.

### Results

To determine whether an individual participant learned the cue, we computed the log-likelihood ratio (LLR) between the _change_ model and the null hypothesis (the _no change_ model), and tested whether $2\cdot{}\mathrm{LLR}$ was significantly greater than zero under the $\chi^2$ distribution, with a significance threshold of $p=`EXP1_SWITCH_THRESHOLD`$.
Using this analysis, we found that `EXP1_SWITCH_FB` participants in the _feedback_ condition switched to a cue-based strategy while `EXP1_SWITCH_NOFB` participants in the _no feedback_ condition switched.
To ensure these numbers were more than we would expect due to random chance, we additionally performed proportion tests with a probability of chance at `EXP1_SWITCH_THRESHOLD` (corresponding to the significance threshold above). Both proportions were significantly different from chance (for feedback, `EXP1_SWITCH_CHI_FB_NULL`; for no feedback, `EXP1_SWITCH_CHI_NOFB_NULL`). The difference in proportions was also significant (`EXP1_SWITCH_CHI_FB_NOFB`)

<!-- \fred{I'm not sure that this analysis is appropriate: Using the permutation approach we discussed, I found that the cue model is chosen at p=.018, 17 times as often as our assumed null probability of .001. This is with only 20 samples, but it suggests that the assumptions of a chi square test do not hold for our log likelihood ratio. Fortunately, the proportion tests remain significant even when p is set to .05 (a conservative overestimate), so I would be okay with glossing over this detail.} -->

Figure \ref{fig:got-it} shows the two participants in the _no feedback_ condition with the highest log-likelihood ratios, and illustrates the clear effect of the cue: on the *honest* trials, the participants have nearly perfect performance, while on the *neutral* trials, they are significantly worse.

We additionally looked at the overlap between those participants who correctly answered the cue quiz and those who were identified by our model.
The results, shown in Table \ref{tbl:cue}, indicate that those people who were identified by the model answered correctly on the quiz, but not necessarily the other way around.
This suggests that, counter to our second hypothesis, not _everybody_ who explicitly identifies the cue is able to apply that knowledge when performing the task.

# Experiment 2: Discovering new heuristics

\begin{table}[t]
\begin{center}
  \caption{Number of participants identified by the quiz and/or model as having learned the cue in Experiments 1 and 2.\\ FB = ``Feedback'', No FB = ``No Feedback''.}
  \label{tbl:cue}
  \begin{tabular}{clcccc}
    \toprule
    & Condition & \textbf{Neither} & \textbf{Quiz} & \textbf{Model} & \textbf{Both} \\
    & & & \textbf{Only} & \textbf{Only} & \\
    \midrule
    1 & \emph{No FB} (`EXP1_N_NO_FEEDBACK`) `EXP1_TABLE_NOFB` \\
      & \emph{FB} (`EXP1_N_FEEDBACK`) `EXP1_TABLE_FB` \\
    \midrule
    2A & \emph{No FB} (`EXP2_N_NO_FEEDBACK`) `EXP2_TABLE_NOFB` \\
       & \emph{FB} (`EXP2_N_FEEDBACK`) `EXP2_TABLE_FB` \\
    \midrule
    2B & \emph{No FB} (`EXP3_N_NO_FEEDBACK`) `EXP3_TABLE_NOFB` \\
     & \emph{FB} (`EXP3_N_FEEDBACK`) `EXP3_TABLE_FB` \\
    \bottomrule
  \end{tabular}
\end{center}
\end{table}

Based on the results of Experiment 1, it is clear that some people are able to use mental simulation to learn a cue-based heuristic---as long as they know that such a cue exists.
In Experiment 2, we asked whether participants could discover and learn the heuristic without being given this information explicitly.
By making two small alterations to the backstory presented in Experiment 1, we modulated the degree to which participants would expect the cue, leading to large differences in cue-learning.

Experiment 2A did not explicitly inform participants that the colors are predictive; it only associated the cue (color) with players.
We hypothesized that this would allow participants to frame hypotheses about cue predictiveness in terms of more familiar concepts: one player might be more talented or have a different goal.
Additionally, describing the colors in the instructions might increase their salience.
In Experiment 2B, we did not verbally draw attention to the cue, nor did we provide any semantic meaning for the cue.
Thus we expected participants would be even less likely to learn they cue, perhaps because they do not even consider the hypothesis that the colors are predictive.

## Methods

### Participants

We recruited `EXP2_N_PARTICIPANT` participants on Amazon’s Mechanical Turk using the psiTurk experimental framework \citep{gureckis15}.
Participants were treated in accordance with UC Berkeley IRB standards and were paid $1.50 for roughly fourteen minutes of work.
We excluded `EXP2_N_FORMAT` participants who did not finish the experiment and `EXP2_N_CAUGHT` participants who answered incorrectly on more than one catch trial.
This left a total of `EXP2_N_REMAIN` participants in our analysis.

### Design and Procedure

The design and procedure were identical to Experiment 1, with the following exceptions.
In Experiment 2A we told participants that there were three different players, corresponding to three different colors, but not that they were playing different games.
In Experiment 2B we gave participants a minimal backstory that made no reference to players or colors.
In both experiments we only administered the *cue quiz* once, at the end of the experiment.
The quiz in Experiment 2B did not make any reference to players.

## Results

\begin{figure*}[t!]
\begin{center}
  \begin{subfigure}[t]{0.32\textwidth}
    \includegraphics[width=\textwidth]{figs/3/experiments_quiz.pdf}
  \end{subfigure}%
  \begin{subfigure}[t]{0.32\textwidth}
    \includegraphics[width=\textwidth]{figs/3/experiment_differences.pdf}
  \end{subfigure}%
  \begin{subfigure}[t]{0.32\textwidth}
    \includegraphics[width=\textwidth]{figs/3/experiment_models.pdf}
  \end{subfigure}
  \caption{Comparing quiz, accuracy, and model results across experiments. (a) Participants who correctly identified the cue during the cue quiz. The dashed line indicates chance performance, and error bars are bootstrapped 95\% confidence intervals. (b) The difference in accuracy on the \emph{honest} trials versus the \emph{neutral} trials. Positive values indicate that participants were more accurate on \emph{honest} trials. Error bars are bootstrapped 95\% confidence intervals. (c) The proportion of participants identified as having learned the cue by the Markov model. There are no error bars due to the particulars of this analysis; all non-zero proportions are significantly different from chance (see text).}
  \label{fig:compare-exps}
\end{center}
\end{figure*}

### Experiment 2A

We performed the same analyses as in Experiment 1, and found that `EXP2_QUIZ_FB_P`% of people in the *feedback* condition were able to identify the cue in the quiz (`EXP2_QUIZ_CHI_FB_NULL`).
Without feedback, `EXP2_QUIZ_NOFB_P`% of participants identified the cue, which was only marginally significant (`EXP2_QUIZ_CHI_FB_NOFB`).
We did not find an affect of \textsc{cue} in the critical trials (`EXP2_CRIT_ANOVA_GOOD_CUE`), though there was a trend towards people being more accurate on *honest* trials.
<!-- Similarly, the only effect we found in the standard trials was for difficulty (`EXP2_ACC_ANOVA_DIFFICULTY`), as would be expected. -->
Similarly, we found no significant effect of the cue on accuracy in standard trials (`EXP2_ACC_ANOVA_CUE`).

The Markov model identified `EXP2_SWITCH_FB` people in the *feedback* condition (`EXP2_SWITCH_CHI_FB_NULL`) and `EXP2_SWITCH_NOFB` in the *no feedback* condition as having adopted the cue strategy.
Together, these results show that when people are primed with a cover story that makes the cue plausible, some of them will indeed learn the cue; however, the majority still will not.

<!-- 
EXP2_SWITCH_FB
EXP2_SWITCH_NOFB
EXP2_SWITCH_CHI_FB_NULL
EXP2_SWITCH_CHI_NOFB_NULL
EXP2_SWITCH_CHI_FB_NOFB
 -->

### Experiment 2B

Whereas in Experiment 2A the cue was explained with a cover story about people playing a game, in Experiment 2B the cue was entirely unexplained.
The results suggest that when the cue is unexplained, participants are highly unlikely to discover the informativeness of the cue.
We again performed the same analyses as those in Experiment 1, and found that people were not significantly different from chance at identifying the cue in the survey, regardless of whether they saw feedback (`EXP3_QUIZ_NOFB_P`% of participants, `EXP3_QUIZ_CHI_FB_NULL`) or not (`EXP3_QUIZ_FB_P`% of participants, `EXP3_QUIZ_CHI_NOFB_NULL`).
We also found no effect of \textsc{cue} in the critical trials (`EXP3_CRIT_ANOVA_GOOD_CUE`), though as in Experiment 2A there was a trend toward people being more accurate on the *honest* trials.
Again, we found no significant effect of the cue on accuracy in standard trials (`EXP3_ACC_ANOVA_CUE`).

The Markov model identified `EXP3_SWITCH_FB` people in the *feedback* condition (`EXP3_SWITCH_CHI_FB_NULL`) and `EXP3_SWITCH_NOFB` in the *no feedback* condition as having adopted the cue strategy.
Generally, these results suggest that when people are not already entertaining the hypothesis that a heuristic might exist, it is highly unlikely that they will spontaneously realize it.

### Comparing Experiments

Summary results of the three experiments are shown in Table \ref{tbl:cue} and Figure \ref{fig:compare-exps}.
We consistently find more evidence for cue-learning when feedback is given.
However, our results suggest that an unexplained cue that has no intuitive relationship with the outcome is quite difficult to learn, even when feedback is present.

# Conclusion

In this work, we asked three questions: (1) are people able to learn about auxiliary properties in the world through mental simulation; (2) do they use their knowledge to make more accurate predictions; and (3) is mental simulation as reliable as real-world experience?
Through our experiments, we showed that people can indeed learn heuristics or cues through the use of mental simulation, but only when they have strong prior expectations that such cues exist.
We additionally find that mental simulation is not as reliable as real-world experience, and that even when people do pick up on cues through mental simulation, they may not use them.
We speculate that this may be happening because people's mental simulations are noisy, and thus  people may not believe the cue is reliable without observing the evidence first hand.
An interesting direction for future research will be to investigate to what extent the reliability of mental simulation affects cue learning.

More broadly, our experiments suggest that mental simulation on its own is not sufficient for learning: prior expectations are hugely important.
This result is consistent with the ideas behind the hypothesis of theory-based causal induction \citep{Tenenbaum2006}, which posits that inductive reasoning requires highly structured and systematic systems of causal knowledge.
While it was possible for participants in our experiments to learn a new piece of causal knowledge (a heuristic), it was very difficult for them to do so if the cue did not easily fit into an existing causal framework.
Thus, we suggest that while mental simulation can be a powerful tool for re-representing knowledge, it does not operate in a vacuum, and must work in tandem with other cognitive processes to fully realize its potential.

<!-- Recent work in psychology and neuroscience has examined similar issues in the context of reinforcement learning which makes a distinction between "model-based" and "model-free" strategies.
The fact that humans use both kinds of strategies is rarely contested, but the ways in which the two systems interact is uncertain.
Under the competitive account, an agent selects between the two systems based on their relative certainty \citep{daw05} or based on a speed-accuracy trade-off \citep{kool16}.
In contrast, the cooperative account suggests that the two systems work together.
For example, model-based system may simulate experiences to train a model-free system that controls behavior \citep{sutton90,daw11,gershman14}.

Our theory lies somewhere in between these two poles.
On one hand, we suggest that people do not rely entirely on a model-free system to control behavior; rather, they switch between model-based and model-free strategies based on the availability of useful heuristics.
On the other hand, we advocate the idea that the model-free system can learn from the model-based system; in fact, we suggest that such teaching occurs in the process of real decision making, not just in offline simulations.

More generally, we see this work as part of a widespread attempt to integrate two poles of psychology, one focusing on processes and heuristics, the other focusing on models and rationality.
Rather than arguing for the relatively greater importance of one or the other, we suggest that part of what makes human cognition successful is the integration of these two ways of thinking. -->


<!-- for autocompletion
EXP1_N_PARTICIPANT EXP1_N_CAUGHT EXP1_N_FORMAT EXP1_N_REMAIN EXP1_N_RT_CLIP EXP1_THRESHOLD_RT_CLIP EXP1_N_NO_FEEDBACK EXP1_N_FEEDBACK EXP1_N_STIM EXP1_N_TRIAL EXP1_N_HIT EXP1_N_MISS EXP1_N_EASY EXP1_N_MEDIUM EXP1_N_HARD EXP1_ACC_ANOVA_CUE EXP1_ACC_ANOVA_FEEDBACK EXP1_ACC_ANOVA_DIFFICULTY EXP1_ACC_ANOVA_CUE_FEEDBACK EXP1_ACC_ANOVA_CUE_DIFFICULTY EXP1_ACC_ANOVA_FEEDBACK_DIFFICULTY EXP1_ACC_ANOVA_CUE_FEEDBACK_DIFFICULTY EXP1_ACC_EASY_NOFB EXP1_ACC_MEDIUM_NOFB EXP1_ACC_HARD_NOFB EXP1_ACC_EASY_FB EXP1_ACC_MEDIUM_FB EXP1_ACC_HARD_FB EXP1_ACC__NOFB EXP1_ACC__FB EXP1_ACC_CUE_NEUTRAL EXP1_ACC_CUE_HONEST EXP1_CRIT_ANOVA_FEEDBACK EXP1_CRIT_ANOVA_GOOD_CUE EXP1_CRIT_ANOVA_FEEDBACK_GOOD_CUE EXP1_CRIT_NOFB_ZTEST EXP1_CRIT_FB_ZTEST EXP1_QUIZ_NOFB_P EXP1_QUIZ_FB_P EXP1_QUIZ_CHI_FB_NULL EXP1_QUIZ_CHI_NOFB_NULL EXP1_QUIZ_CHI_FB_NOFB EXP1_SWITCH_THRESHOLD EXP1_SWITCH_FB EXP1_SWITCH_NOFB EXP1_SWITCH_CHI_FB_NULL EXP1_SWITCH_CHI_NOFB_NULL EXP1_SWITCH_CHI_FB_NOFB EXP1_TABLE_NOFB EXP1_TABLE_FB EXP3_N_PARTICIPANT EXP3_N_CAUGHT EXP3_N_FORMAT EXP3_N_REMAIN EXP3_N_RT_CLIP EXP3_THRESHOLD_RT_CLIP EXP3_N_NO_FEEDBACK EXP3_N_FEEDBACK EXP3_N_STIM EXP3_N_TRIAL EXP3_N_HIT EXP3_N_MISS EXP3_N_EASY EXP3_N_MEDIUM EXP3_N_HARD EXP3_ACC_ANOVA_CUE EXP3_ACC_ANOVA_FEEDBACK EXP3_ACC_ANOVA_DIFFICULTY EXP3_ACC_ANOVA_CUE_FEEDBACK EXP3_ACC_ANOVA_CUE_DIFFICULTY EXP3_ACC_ANOVA_FEEDBACK_DIFFICULTY EXP3_ACC_ANOVA_CUE_FEEDBACK_DIFFICULTY EXP3_ACC_EASY_NOFB EXP3_ACC_MEDIUM_NOFB EXP3_ACC_HARD_NOFB EXP3_ACC_EASY_FB EXP3_ACC_MEDIUM_FB EXP3_ACC_HARD_FB EXP3_ACC__NOFB EXP3_ACC__FB EXP3_ACC_CUE_NEUTRAL EXP3_ACC_CUE_HONEST EXP3_CRIT_ANOVA_FEEDBACK EXP3_CRIT_ANOVA_GOOD_CUE EXP3_CRIT_ANOVA_FEEDBACK_GOOD_CUE EXP3_CRIT_NOFB_ZTEST EXP3_CRIT_FB_ZTEST EXP3_QUIZ_NOFB_P EXP3_QUIZ_FB_P EXP3_QUIZ_CHI_FB_NULL EXP3_QUIZ_CHI_NOFB_NULL EXP3_QUIZ_CHI_FB_NOFB EXP2_N_PARTICIPANT EXP2_N_CAUGHT EXP2_N_FORMAT EXP2_N_REMAIN EXP2_N_RT_CLIP EXP2_THRESHOLD_RT_CLIP EXP2_N_NO_FEEDBACK EXP2_N_FEEDBACK EXP2_N_STIM EXP2_N_TRIAL EXP2_N_HIT EXP2_N_MISS EXP2_N_EASY EXP2_N_MEDIUM EXP2_N_HARD EXP2_ACC_ANOVA_CUE EXP2_ACC_ANOVA_FEEDBACK EXP2_ACC_ANOVA_DIFFICULTY EXP2_ACC_ANOVA_CUE_FEEDBACK EXP2_ACC_ANOVA_CUE_DIFFICULTY EXP2_ACC_ANOVA_FEEDBACK_DIFFICULTY EXP2_ACC_ANOVA_CUE_FEEDBACK_DIFFICULTY EXP2_ACC_EASY_NOFB EXP2_ACC_MEDIUM_NOFB EXP2_ACC_HARD_NOFB EXP2_ACC_EASY_FB EXP2_ACC_MEDIUM_FB EXP2_ACC_HARD_FB EXP2_ACC__NOFB EXP2_ACC__FB EXP2_ACC_CUE_NEUTRAL EXP2_ACC_CUE_HONEST EXP2_CRIT_ANOVA_FEEDBACK EXP2_CRIT_ANOVA_GOOD_CUE EXP2_CRIT_ANOVA_FEEDBACK_GOOD_CUE EXP2_CRIT_NOFB_ZTEST EXP2_CRIT_FB_ZTEST EXP2_QUIZ_NOFB_P EXP2_QUIZ_FB_P EXP2_QUIZ_CHI_FB_NULL EXP2_QUIZ_CHI_NOFB_NULL EXP2_QUIZ_CHI_FB_NOFB EXP2_SWITCH_THRESHOLD EXP2_SWITCH_FB EXP2_SWITCH_NOFB EXP2_SWITCH_CHI_FB_NULL EXP2_SWITCH_CHI_NOFB_NULL EXP2_SWITCH_CHI_FB_NOFB EXP2_TABLE_NOFB EXP2_TABLE_FB EXP3_SWITCH_THRESHOLD EXP3_SWITCH_FB EXP3_SWITCH_NOFB EXP3_SWITCH_CHI_FB_NULL EXP3_SWITCH_CHI_NOFB_NULL EXP3_SWITCH_CHI_FB_NOFB EXP3_TABLE_NOFB EXP3_TABLE_FB EXPALL_ANOVA__INTERCEPT EXPALL_ANOVA_EXPERIMENT EXPALL_ANOVA_FEEDBACK EXPALL_ANOVA_EXPERIMENT_FEEDBACK EXPALL_ANOVA__RESIDUALS EXPALL_COMP_EXP1_FALSE EXPALL_COMP_EXP2_FALSE EXPALL_COMP_EXP3_FALSE EXPALL_COMP_EXP1_TRUE EXPALL_COMP_EXP2_TRUE EXPALL_COMP_EXP3_TRUE EXP23_N_PARTICIPANT EXP23_N_CAUGHT EXP23_N_FORMAT EXP23_N_REMAIN 
 -->
