# Offline Wellbeing Companion App — Product Description & Research Scope

*Working name: "Firefly". Compiled 30 Sep 2026 from a design conversation plus a targeted literature scan (~17 searches). Purpose: a single hand-off document so research can continue with an assistant without losing context.*

> **How to read the evidence tags**
> - **[Verified]** = found in a source retrieved during this session (abstract, publisher page, PubMed/PMC, university/press summary).
> - **[Unverified]** = claimed from background knowledge in the first brainstorm; not yet checked against a source. Verify before relying on it.
> - **[My suggestion]** = design idea or inference, not a research finding.
> - Effect sizes: g/d/SMD are standardized mean differences (≈0.2 small, 0.5 medium, 0.8 large). Negative sign = symptom reduction.
> - Many "Verified" items were confirmed from abstracts or secondary summaries, not full papers. Re-read primary papers before citing in academic work.

---

## 1. Product vision

A calm, private, **fully offline** mobile app that stays with a person on hard days (stressed, low, overwhelmed, lonely) and guides them through **one small, evidence-informed step at a time**. It should feel like a quiet companion offering serenity and comfort in loneliness, not a clinical tool or a productivity tracker. Everything stays on the device.

**Positioning:** supports, does not replace, professional care. It does not diagnose.

### Target users
People going through stress, low mood, overwhelm, or loneliness, including at night or when no one is available. Best fit is mild-to-moderate distress (see evidence limits, §7). Users in crisis are routed to their safety plan and human help.

### Core design principles
- Minimal text, big buttons, dark/low-stimulation mode
- One step at a time; nothing overwhelming on screen
- No guilt notifications, no gamified streaks; gentle progress only ("You showed up 4 times this week")
- Warm, non-clinical tone
- Private by default: encrypted local storage, no account, no cloud required
- Value delivered in under ~2 minutes per visit (see engagement data, §4)

### Guardrails
- State clearly it supports, not replaces, professional care
- If entries suggest crisis, surface the safety plan and helplines; do not diagnose
- Have clinicians/psychologists review all content before release
- Safety plan and crisis resources always one tap away, stored offline
- [My suggestion] Any on-device language model must be constrained to reflective prompts, with crisis-language detection routing to the safety plan

### Technical outline (offline)
- Encrypted local database (SQLite)
- On-device rule-based flows (primary)
- Optional small on-device language model for reflective prompts only
- Local audio (ambient sounds), haptics, voice-to-text journaling on-device
- No cloud dependency (also improves privacy and trust)

---

## 2. Feature catalogue (original + new)

### Original MVP suggestion
Check-in, breathing/grounding, tiny steps, journaling, safety plan.

### A. Original features (from first brainstorm)

| # | Feature | Description |
|---|---|---|
| A1 | **"How are you right now?" check-in** | Quick mood/energy tap, no long questionnaires. Suggests one action matched to state. |
| A2 | **Grounding & breathing** | 5-4-3-2-1 senses exercise; slow paced breathing; haptics and soft audio. |
| A3 | **Tiny-steps mode (behavioral activation)** | 2-minute actions when low ("drink water", "open a window"). |
| A4 | **Thought untangler (CBT-lite) + self-compassion** | Prompts like "What am I telling myself? What would I tell a friend?" |
| A5 | **Unsent letters & expressive journaling** | Optional auto-delete; on-device voice-to-text. |
| A6 | **Loneliness comfort ("Someone's here")** | Gentle ambient sounds, slow-breathing visual, "Things that helped before" box, "People I could reach out to" with one-tap pre-written texts (e.g., "Hey, having a rough day. Can we talk?"). |
| A7 | **Safety plan** | Stanley-Brown–style: warning signs, coping steps, contacts, local crisis numbers, saved offline. |
| A8 | **Gentle progress** | No streak pressure; simple "you showed up" summaries. |

### B. New feature proposals (from research scan)

| # | Feature | Description |
|---|---|---|
| B1 | **One-Session Reset** | Self-contained 5–10 min guided module (name the problem → one skill → one small commitment) that works even if the user never returns. |
| B2 | **"Guess vs. Reality"** (loneliness) | Before texting someone, user rates expected outcome; afterward logs what happened; app shows the gap over time. Pairs with A6's pre-written texts. |
| B3 | **Awe Walk** | 15-minute "look up and out" outdoor prompt, ideally somewhere new; offline prompt cards (e.g., "find something vast", "notice something tiny"). |
| B4 | **Movement Snacks** | 2–10 minute movement options matched to check-in: gentle for anxious, graded ladder for low energy. |
| B5 | **Wind-Down (sleep)** | Sleep diary, fixed wake-time nudge, pre-bed "worry dump", gentler CBT-I components first. |
| B6 | **Hope Box** | Private space for photos, voice notes from loved ones, favorite songs, reasons to keep going, small goals. Upgrade of "Things that helped before". |
| B7 | **Music Room** | Import own music; "calm down" and "gentle lift" sets; slow soundscapes. |
| B8 | **Weekly Check-in Buddy** | User picks a trusted person; app prompts a ~2-minute weekly summary the user may choose to send. |

---

## 3. Evidence by feature

### 3.0 Digital/app interventions overall
- **Linardon et al., meta-analysis of 176 RCTs** [Verified; abstract]: apps had small but significant effects vs controls on depression (N=33,567, g=0.28, NNT=11.5) and generalized anxiety (N=22,394, g=0.26, NNT=12.4). Effects robust at follow-ups and after removing small/high-risk-of-bias trials. Outcomes were less variable in app groups than control groups. Builds on a 2019 meta-analysis showing positive but variable effects. Abstract points to specific app features (e.g., CBT, mood monitoring) as moderators; the sentence was truncated in the retrieved text, so **check the full paper**.
- **Firth et al. 2017, *World Psychiatry*** [Verified]: first meta-analysis of smartphone apps for depression; 18 RCTs, 22 apps, 3,414 participants; symptoms reduced significantly more than controls. Reported as best for mild-to-moderate depression; major depression less studied.
- **Firth et al. 2017, *J Affective Disorders*** [Verified]: first meta-analysis of smartphone interventions for anxiety; 1,837 people; anxiety reduced significantly more than controls. Authors suggest apps augment rather than replace care; apps promoting overall wellbeing may be most consistently effective.

### 3.1 Engagement and human support (design-critical)
- **Baumel et al. 2019, *JMIR* 21(9):e14567** [Verified]: independent traffic data on popular unguided apps (Google Play, Nov 2018, >10,000 installs; 59 apps had 30-day retention data).
  - Median retention: **3.9% at day 15** (IQR 10.3%), **3.3% at day 30** (IQR 6.2%).
  - Median daily minutes among active users: mindfulness/meditation 21.47; peer support 35.08 (n=2 apps); tracker/breathing/psychoeducation apps roughly 3.5–8.3.
  - Day-30 retention: peer support 8.9% (n=2), tracker 6.1%, mindfulness 4.7%, **breathing-exercise apps 0.0%**.
  - Use peaked in the evening for most app types; mindfulness had morning and night peaks.
  - Caveat from commentary: low retention may partly mean the app's purpose was fulfilled quickly (e.g., a breathing technique), and with millions of installs even low retention reaches many people.
- **Guidance and adherence, *Psychological Medicine* 52(2):229–240** [Verified]: meta-analysis of 22 studies (mostly depression/anxiety). Human guidance increased intervention completion (g=0.29, 95% CI 0.18–0.40; log OR 0.50), with full completion about **12% higher** in guided groups.
- **Shim et al., *Clinical Psychology Review* 57 (scoping review)** [Verified]: 19 studies, seven categories of human-support factors. Only one feature clearly improved outcomes: **scheduled** support beat unscheduled support. Mixed findings on guided vs unguided and human vs automated support. Level of therapist expertise may matter little. Caution: limited research.
- **van Ballegooijen et al. 2014, *PLOS ONE*** [Verified]: completers of face-to-face CBT 84.7% vs guided internet CBT 65.1%; non-completers of guided iCBT still completed more of the program (42.1% vs 24.5%).
- Background from a self-help review [Verified, secondary]: unguided internet self-help for depression shows a wide range of effects (g = 0.02–1.56), higher dropout and lower adherence; one trial comparison noted guided advantages faded at 6–12-month follow-up.

### 3.2 A1 Check-in / affect labeling
- [Unverified] Claim in first brainstorm: labeling emotions ("affect labeling") reduces amygdala reactivity (Lieberman-type research). **Not searched yet.**
- [Verified, indirect] Linardon abstract lists mood monitoring among app features studied; effect of monitoring on rumination not yet examined (see §9).

### 3.3 A2 / B-breathing and grounding
- **Balban et al. 2023, *Cell Reports Medicine* 4(1):100895** [Verified]: remote randomized trial (NCT05304000) comparing three daily 5-minute breathwork exercises (cyclic sighing = emphasized prolonged exhale; box breathing; cyclic hyperventilation with retention) with equal-time mindfulness meditation over 1 month, with wearable physiology. Both breathwork and mindfulness improved daily positive affect and reduced state anxiety and negative affect. **Breathwork, especially cyclic sighing, produced greater mood improvement and larger reduction in respiratory rate than mindfulness**; the effect increased with more days of practice. Authors: daily 5-min cyclic sighing shows promise as stress management.
- [Unverified] First-brainstorm claim: slow paced breathing (~6 breaths/min) linked to better heart-rate variability and lower anxiety.
- [Unverified] 5-4-3-2-1 grounding: no trial evidence retrieved.
- **Design implication [My suggestion]:** default to cyclic sighing; embed breathing inside other flows rather than as a standalone tile, given Baumel's 0% median day-30 retention for breathing apps.

### 3.4 A3 Behavioral activation (tiny steps)
- ***Psychological Medicine* 2021;51(9):1491–1504** [Verified]: 28 studies. BA beat inactive controls for depression (g=0.83), anxiety (g=0.37) and activation (g=0.64). Vs active controls: not significant (depression g=0.15; anxiety 0.03; activation 0.04). No evidence that discussing values augmented BA. Study quality generally low; publication bias evident.
- **Ciharova et al. 2021, *J Consulting & Clinical Psychology* 89(6):563–574** [Verified]: network meta-analysis of face-to-face treatments; BA may be similarly effective to full CBT; conclusions about cognitive restructuring alone not possible.
- **Sturmey 2009** systematic review [Verified via summary]: BA superior to waitlist/usual care, no different from CBT or cognitive therapy, possibly lower dropout.
- **Limit:** these are mainly therapist-delivered trials; an unguided app version is a hypothesis.

### 3.5 A4 Thought untangler and self-compassion
- **Han & Kim 2023, *Mindfulness*** [Verified]: 56 RCTs; small-to-medium effects on depressive symptoms, anxiety and stress at post-test; small effects on depression and stress at follow-up; overall risk of bias high; few online interventions and few in people with distress symptoms.
- **Ferrari et al. 2019, *Mindfulness* 10:1455–1473** [Verified]: 27 RCTs, 11 outcomes. Large effects: eating behavior g=1.76, rumination g=1.37. Moderate: self-compassion 0.75, stress 0.67, depression 0.66, mindfulness 0.62, anxiety 0.57, self-criticism 0.56. Depression gains kept increasing at follow-up; stronger for group than individual delivery; possible publication bias; intervention types too varied to compare.
- **MacBeth & Gumley 2012** (cited in a Stirling review) [Verified, secondary]: self-compassion correlates with lower depression/anxiety/stress (r = −0.54 in adults). A review of third-wave therapies found improvements in self-compassion and psychopathology but not beyond other interventions.
- [Unverified] Neff's self-compassion work as especially helpful for shame/self-criticism (first brainstorm).

### 3.6 A5 Expressive writing / journaling
- **Frattaroli 2006** [Verified via secondary sources]: meta-analysis of 146 randomized disclosure studies. Better outcomes with **3+ writing sessions, sessions ≥15 min, more specific instructions, and writing at home/private space**. Stronger health effects in high-stress samples. Psychological benefits shorter-lived at longer follow-up. Reported overall effect small (one source cites 0.075; a review cites d range 0.13–0.47 across meta-analyses).
- **Mixed literature** [Verified]: benefits reported by Frattaroli 2006, Frisina 2004, Pavlacic 2019, Travagin 2015; no improvement reported by Meads & Nouwen 2005 and Reinhold 2018. Harris (2006) found reduced healthcare use in healthy samples but not in clinical/psychiatric samples (secondary source).
- **Newer meta-analysis** [Verified; abstract truncated]: 31 RCTs (N=4,012), healthy/subclinical samples; overall small but significant effect on depression, anxiety, stress; moderators examined (instructions, sessions, spacing, delivery mode).
- Reinhold et al. 2018 (via Frontiers review) [Verified, secondary]: session length and number matter; longer spacing between sessions helpful.
- **Design implication [My suggestion]:** multi-day sequence, private, skippable; do not push trauma writing when acutely distressed (samples were mostly healthy/subclinical).
- [Unverified] "15–20 minutes" Pennebaker figure from first brainstorm (roughly consistent with the ≥15 min moderator).

### 3.7 A6 / B2 Loneliness
- **Masi et al. 2011, *Personality & Social Psychology Review* 15(3):219–266** [Verified]: meta-analysis of loneliness interventions (secondary summaries say ~50 studies). Four strategies: improving social skills, enhancing social support, increasing opportunities for social contact, **addressing maladaptive social cognition**. Single-group pre-post and non-randomized studies showed larger effects than randomized ones. Among randomized studies, **interventions addressing maladaptive social cognition were most successful**. Secondary source claims roughly three-fold larger effect (not verified in primary text). Rationale: lonely people show heightened sensitivity to negative social cues and hold negative expectations.
- **"The surprise of reaching out," *J Personality & Social Psychology* 2023;124(4):754–771** [Verified]: preregistered experiments show robust **underestimation of how much others appreciate being reached out to** (check-in messages, small gifts). Mechanism: recipients focus on feelings of surprise, which predicts greater appreciation. Underestimation is larger when the context is surprising and when the recipient is socially more distant.
- **Kumar & Epley, "Undervaluing gratitude," *Psychological Science*** [Verified]: four experiments; letter writers underestimated recipients' surprise and positive feelings, overestimated awkwardness, and underestimated how warm and competent they would seem. Lower confidence about writing ability reduced willingness to send.
- **Kumar & Epley 2023, "Undersociality is unwise," *J Consumer Psychology* 33(1):199–212** [Verified as reference]; Epley's book *A Little More Social* (2026) [Verified as reference]: people underestimate benefits of connecting; not reaching out prevents learning that the fear was wrong.
- **Design implications [My suggestion]:** B2 prediction-vs-outcome log operationalizes belief testing; A6's pre-written texts lower friction; gratitude-message nudges are a lightweight variant.
- Note: Masi's finding is about cognitively oriented interventions (CBT-style), typically delivered with facilitation; an unguided app version is untested.

### 3.8 A7 Safety plan and B6 Hope Box
- **Stanley et al. 2018, *JAMA Psychiatry* 75(9):894–900** [Verified]: cohort comparison in Veterans Affairs emergency departments. Safety Planning Intervention + structured follow-up phone contact (SPI+; n=1,186) vs usual care (n=454). Suicidal behavior over 6 months: **3.03% vs 5.29%** (OR 0.56, P=0.03); ≥1 outpatient mental-health visit: OR 2.06 (P<0.001). Six steps: warning signs; internal coping strategies; people/places for distraction; people to ask for help; professionals/agencies to contact; making the environment safer (lethal-means counseling). Delivered by trained clinician; first follow-up call within 72 hours after discharge; further calls if no outpatient appointment. (Sources differ on number of sites: five vs nine EDs.) A state program summary reports 45% fewer suicidal behaviors and ~30 min to complete.
- **ED-SAFE 2 (*JAMA Psychiatry* 2023)** [Verified as existing; only news summary read]: stepped-wedge cluster RCT, 2,761 ED-discharged patients screening positive for suicide risk; ED-initiated SPI associated with reduced subsequent suicide behaviors over 12 months per report. **Read the primary paper for exact outcomes.**
- **Bush et al. 2017, "A Virtual Hope Box," *Psychiatric Services* 68(4):330–336** [Verified]: RCT, 118 veterans in mental-health treatment with recent suicidal ideation (enrolled Mar 2014–Apr 2015); VHB (n=58) vs printed coping materials (n=60) over 12 weeks (NCT01982773). VHB users reported **greater coping self-efficacy** at 3 weeks (b=2.41, 95% CI 0.29–4.55) and 12 weeks (b=2.99, 95% CI 0.08–5.90). **No significant advantage** on suicidal ideation, reasons for living, or other measures. Common uses: coping with distress and overwhelming emotions, relaxation, distraction, inspiration. Traditional hope-box contents: photos of loved ones, certificates of achievement, lists of future aspirations, relaxing music, recordings from loved ones.
- **Limits and design implications [My suggestion]:** the strongest safety-plan evidence involves clinician-delivered plans with follow-up; the app should encourage completing the plan with a clinician or trusted person and include follow-up reminders. Position the Hope Box as a coping aid, not treatment.

### 3.9 B1 One-Session Reset (single-session interventions)
- **Schleider & Weisz 2017, *J American Academy of Child & Adolescent Psychiatry* 56(2):107–115** [Verified]: 50 RCTs, 10,508 youths; mean post-intervention **g=0.32**. Effects only slightly smaller than multi-session treatments and not different for youth with more or less serious problems or with/without diagnosis (author summary). Effects varied by target problem (a secondary report cites the largest, 1.05, for eating-disorder-focused SSIs). Rationale: up to 75% of youth with needs never receive services and early dropout is common.
- **Schleider et al., *Annual Review of Clinical Psychology* (2025 review)** [Verified via press release]: SSIs significantly improve mental-health outcomes in youth and adults; reviewed 24 systematic reviews; headline states 83% of studies reported positive effects. Author argues digital, self-guided SSIs can fill gaps left by weekly psychotherapy. **Check primary paper for details and quality ratings.**

### 3.10 B3 Awe Walk
- **Sturm et al. 2020, *Emotion* ("Big smile, small self")** [Verified]: older adults took weekly 15-minute "awe walks" for 8 weeks; increased positive emotions (including prosocial emotions like compassion and gratitude) and less daily distress; selfies showed increasing focus on surroundings and broader smiles. Instructions encouraged nature and new places. Compared with a similar but less instructed walk. **Small sample** (reported as 52 or 60 across sources), initially healthy older adults; authors speculate larger gains possible with more distress but this is untested.
- Related lab work (Rudd et al., via secondary source) [Verified, weak]: brief awe can expand perceived time and raise life satisfaction.

### 3.11 B4 Movement Snacks
- **Noetel et al. 2024, *BMJ* 384:e075847** [Verified]: network meta-analysis for major depressive disorder (secondary report: >200 studies, ~14,000 participants). Versus active controls: walking/jogging g=−0.62 (n=1,210, k=51), yoga −0.55, strength training −0.49, mixed aerobic −0.43, tai chi/qigong −0.42. **Effects proportional to prescribed intensity.** Strength training and yoga most acceptable. Exercise worked with and without comorbidities and across baseline severity. **Confidence low (walking/jogging) to very low (others)**; only one study at low risk of bias.
- **Munro et al. 2026, *British Journal of Sports Medicine* (in press), umbrella review** [Verified]: 63 reviews (81 meta-analyses; 1,079 component studies; 79,551 participants). Depression SMD −0.61 (95% CI −0.69 to −0.54); anxiety SMD −0.47 (−0.59 to −0.36). Aerobic exercise strongest. Largest depression benefits in ages 18–30 and postnatal women; greater with group and supervised settings. **Shorter duration and lower intensity most strongly associated with anxiety reduction.**
- **Design implication [My suggestion]:** state-matched menu (gentle for anxious; graded ladder for low energy); encourage doing it with someone when possible. Populations in these trials were mostly clinical or subclinical adults; unguided micro-doses are untested.

### 3.12 B5 Wind-Down (sleep)
- **Lee et al. 2023, *npj Digital Medicine* 6:52** [Verified]: 22 RCTs (2,504 records after de-duplication) in adults with insomnia; digital CBT-I significantly reduced insomnia, depression and anxiety; effects held when accounting for adherence and with fully automated delivery.
- **Lin et al. 2023, *PeerJ* (doi 10.7717/peerj.16137)** [Verified]: digital CBT-I reduced insomnia (short-term SMD −0.85, 95% CI −1.00 to −0.69; long-term −0.71) and depression (short-term −0.47, CI −0.55 to −0.38; long-term −0.42, CI −0.68 to −0.15); comparable to face-to-face CBT-I; maintained 6 weeks–6 months.
- **Cao et al. 2026 medRxiv individual-participant-data meta-analysis (preprint, not peer-reviewed)** [Verified]: two Australian RCTs (digital behavioural therapy for insomnia built around sleep restriction, "SleepFix"; n=220 vs 270; mean age 66); anxiety reduced at week 8 (−0.94 GAD-7 points). Treat as preliminary.
- Oxford professor quoted in trade coverage: improving sleep likely lessens anxiety and depression [Verified, weak].
- **Design implication [My suggestion]:** start with gentler components (diary, wind-down, consistent wake time, worry dump); sleep restriction is the harder component and is not recommended for v1.

### 3.13 B7 Music Room
- **Harney et al. 2022, *Musicae Scientiae*** [Verified]: 24 controlled studies (21 in meta-analysis; 6,208 records screened); music listening reduced anxiety with a large effect (d=−0.77, 95% CI −1.26 to −0.28); authors call for research in clinical groups.
- **Panteleeva et al. 2018, *Psychology of Music* 46(4):473–487** [Verified]: 19 RCTs in healthy individuals; self-reported anxiety d=−0.30 (95% CI −0.55 to −0.04); no significant effect on psychophysiological signals overall; high heterogeneity and weak methodological standards.
- **Front Psychol 2017;8:1109** [Verified]: review of 28 studies (1,810 participants) of music/music therapy for depressive symptoms; 26 showed significant depression reduction vs comparison; group settings slightly better; not all randomized.
- NCCIH digest [Verified, indirect]: in a 2017 meta-analysis of 14 RCTs (1,178 participants) on chronic pain, music chosen by the participant had a greater effect than researcher-chosen music. A chemotherapy-setting review found reduced anxiety (SMD −0.29) but no depression effect, with low-quality evidence.
- **Design implication [My suggestion]:** user-imported music; note effect sizes vary widely across reviews.

### 3.14 B8 Weekly Check-in Buddy
- Rationale from §3.1: guidance raised completion (about +12%) and scheduled support outperformed unscheduled support. **No trial found testing a friend or family member in the guide role**; findings on human vs automated support are mixed. Treat as a design hypothesis with privacy safeguards (user controls what is shared).

### 3.15 A8 Gentle progress / no streaks
- No direct evidence retrieved. [My suggestion] rationale: fragile mood, guilt avoidance, and the fact that median retention is low anyway (§3.1). Evidence on streaks/gamification in mental-health apps remains to be reviewed.

---

## 4. Evidence-strength snapshot (my qualitative judgment)

| Feature | Evidence for related intervention | Evidence for unguided offline app version | Main caveat |
|---|---|---|---|
| A2 Breathing (cyclic sighing) | Moderate (one RCT, remote, 1 month) | Untested | Poor real-world retention of breathing-only apps |
| A3 Tiny steps / BA | Moderate–strong for therapy | Untested | Low study quality; therapist-delivered |
| A4 Self-compassion | Moderate (many RCTs) | Few online trials | High bias risk; publication bias |
| A5 Expressive writing | Weak–mixed | Untested | Small effects; some null meta-analyses; short-lived |
| A6/B2 Loneliness / social cognition | Moderate (Masi); strong basic-science signal on reaching out | Untested | Facilitated interventions; small randomized subset |
| A7 Safety plan | Promising (cohort; ED-SAFE 2 trial) | Untested | Clinician-delivered with follow-up |
| B1 Single-session | Moderate (50 RCTs youth; reviews in adults) | Digital SSIs studied by authors' lab | Youth-heavy evidence |
| B3 Awe walk | Preliminary | Untested | Small healthy older-adult sample |
| B4 Movement | Moderate–strong overall | Untested | Low-certainty ratings; prescribed intensity |
| B5 Sleep (dCBT-I) | Strong for digital CBT-I | Fully automated versions studied | Sleep restriction needs care |
| B6 Hope Box | Weak (one RCT) | Tested (app vs print) | Improved coping only; no effect on ideation |
| B7 Music | Mixed–moderate | Untested | Heterogeneous, low quality |
| B8 Check-in buddy | Indirect | Untested | Extrapolation |

---

## 5. Cross-cutting design implications

1. **Assume people won't come back.** Median 15-day retention 3.9%: make each visit worthwhile in under two minutes; avoid streak mechanics.
2. **Be honest about effect sizes.** Across 176 RCTs apps show small effects (g≈0.28 depression, 0.26 anxiety). Position the app as a complement to care.
3. **Add human touchpoints** (B8, safety-plan follow-up reminders, "people I could reach out to").
4. **Time and context:** usage peaks in the evening; mindfulness has morning and night peaks. Consider evening-weighted prompts and a night-time mode.
5. **State-matched suggestions:** the check-in picks one action (breathing when anxious, tiny step when low, connection prompt when lonely).

---

## 6. MVP and roadmap (from conversation)

- **MVP:** check-in, breathing/grounding, tiny steps, journaling, safety plan.
- **Next (evidence-supported adds):** One-Session Reset (B1), Guess vs. Reality (B2), Hope Box (B6), Wind-Down (B5).
- **Later:** Movement Snacks (B4), Music Room (B7), Awe Walk (B3), Check-in Buddy (B8).
- Offered but not yet produced: screen sketches, a feature roadmap, tech-stack proposal.

---

## 7. Known limits of the current evidence and this review

- **Targeted, not systematic.** ~17 searches; abstracts and press summaries, not full texts. Not "all journals."
- Most trials involve mild-to-moderate symptoms, short follow-up, high risk of bias, and often therapist-guided delivery. **Nothing here tests an offline, unguided, multi-feature companion app.**
- Several claims from the first brainstorm remain unverified (affect labeling, HRV/6 breaths/min, Neff, 5-4-3-2-1, Pennebaker specifics).
- Secondary sources conflicted in places (e.g., awe-walk sample size 52 vs 60; safety-plan sites five vs nine; expressive-writing effect sizes).
- A preprint and an in-press paper are included and flagged.

---

## 8. Research scope for further work

### 8.1 Objectives
1. Verify all "Unverified" claims and upgrade "Verified (secondary)" items to primary-source checks.
2. Establish per-feature evidence grades (e.g., GRADE / CINeMA) for **self-guided, mobile, brief** versions of each intervention.
3. Identify which components drive effects in app-based interventions and which harms/adverse effects are reported.
4. Define a validation plan for the offline companion (pilot, outcomes, safety monitoring).

### 8.2 Research questions
- **RQ1** Do self-guided, offline or minimal-connectivity apps achieve outcomes comparable to guided or connected apps? Which features moderate effects?
- **RQ2** Which single-session or micro-dose formats (≤10 min) have RCT support in adults with stress, low mood or loneliness?
- **RQ3** What are the effects of state-matched ("just-in-time") suggestions vs fixed menus?
- **RQ4** Do digital self-compassion, behavioral activation, and belief-testing exercises reduce loneliness in unguided formats?
- **RQ5** Which safe-messaging and crisis-routing designs are supported for self-help apps; what evidence exists on digital safety-plan apps outside clinician delivery?
- **RQ6** What are the risks: rumination from mood tracking, dependence, distress from expressive writing, inappropriate LLM responses?
- **RQ7** How do effects and engagement vary by culture, language, age, and connectivity context?
- **RQ8** What engagement mechanisms (without streaks) improve return use in distressed users?

### 8.3 Suggested search strategy
- **Databases:** PubMed/MEDLINE, PsycINFO, Embase, Cochrane Library, Web of Science, JMIR, IEEE/ACM for HCI.
- **Study types:** meta-analyses, RCTs (incl. micro-randomized trials), qualitative user studies, real-world usage analyses, clinical guidelines.
- **Example concept blocks:** (smartphone OR mobile app OR digital) AND (depress* OR anxiety OR stress OR loneliness) AND (randomi*ed OR meta-analysis) AND (self-guided OR unguided OR brief OR single-session OR just-in-time).
- **Screening/appraisal:** dual screening, risk-of-bias (RoB 2), GRADE or CINeMA, report effect sizes with CIs, separate clinical vs non-clinical samples.

### 8.4 Candidate topics not yet researched (from background knowledge; unverified)
Affect labeling and emotion granularity; HRV biofeedback and resonance breathing; mindfulness programs (MBSR/MBCT) and app-based mindfulness; gratitude and "three good things"; kindness acts; best-possible-self exercises; ACT defusion and values work; scheduled worry time; progressive muscle relaxation; nature-exposure dose; light/circadian interventions; limiting social media use; mood tracking and rumination risk; peer support and moderated communities; just-in-time adaptive interventions (JITAI); digital phenotyping (privacy trade-offs); measurement (PHQ-9, GAD-7, UCLA Loneliness Scale, WEMWBS); crisis-line and text-line integration; adverse events in digital mental-health trials; on-device LLM safety for supportive conversation; regulatory classification (software as a medical device) and app-store health policies; localization to other languages and cultural idioms of distress.

### 8.5 Validation plan (proposal)
1. Clinician content review of all scripts and the safety plan template.
2. Usability testing with small groups (think-aloud, low-vision/low-literacy accessibility).
3. Pilot (e.g., 4–8 weeks) with pre-specified outcomes: distress (PHQ-9/GAD-7 or brief equivalents), loneliness scale, coping self-efficacy, engagement and retention, adverse events.
4. Micro-randomized trial of prompt types and timing.
5. Safety monitoring plan, crisis escalation protocol, data-protection review.

### 8.6 Ethics and safety considerations
Informed consent and clear scope; no diagnostic claims; crisis pathways always accessible; data stays on-device (define backup/export options); testing with vulnerable groups needs ethics oversight; avoid emotionally manipulative engagement tactics; independent clinical review before release.

---

## 9. Open questions / to-do list for the research assistant
1. Retrieve primary papers for: Linardon (176 RCTs), ED-SAFE 2, Annual Review SSI paper, BJSM umbrella review, Balban 2023, Sturm 2020, Kumar & Epley papers, Han & Kim 2023, Ferrari 2019.
2. Verify first-brainstorm claims (affect labeling, paced breathing, Neff, Pennebaker specifics, 5-4-3-2-1).
3. Check whether digital/self-guided versions exist and have RCTs for BA, belief testing, single-session, awe walk, and safety planning.
4. Find evidence on harms and null results (mood tracking, expressive writing, unguided apps).
5. Compile evidence for engagement without streaks; test notification-free designs.
6. Draft an evidence table with columns: intervention, population, design, N, outcome, effect size, follow-up, risk of bias, delivery mode (guided/unguided), relevance to offline app.
7. Decide feature priority using evidence grade × feasibility offline × safety risk.

### Prompt starters for your assistant
- "Do a systematic-style search for self-guided single-session digital interventions in adults with stress or low mood; return an evidence table."
- "Verify the Stanley-Brown Safety Planning Intervention evidence, including ED-SAFE 2 and any digital or self-guided versions."
- "Find RCTs on prediction-vs-outcome (behavioral experiment) exercises for loneliness delivered digitally."
- "Summarize adverse effects reported in trials of mood tracking, expressive writing, and mental-health apps."

---

## 10. Reference list (as retrieved this session)

**Apps, engagement, guidance**
- Linardon J, Torous J, Firth J, Cuijpers P, Messer M, Fuller-Tyszkiewicz M. Efficacy of mental health smartphone apps for depression and anxiety: meta-analysis of 176 RCTs. (World Psychiatry; check year/volume) — https://research.vu.nl/en/publications/current-evidence-on-the-efficacy-of-mental-health-smartphoneapps-/
- Firth J, Torous J, Nicholas J, et al. Efficacy of smartphone-based mental health interventions for depressive symptoms: meta-analysis of RCTs. *World Psychiatry* 2017.
- Firth J, et al. Efficacy of smartphone-based interventions for anxiety. *J Affective Disorders* 2017 — https://www.manchester.ac.uk/about/news/smartphones-new-weapon-in-war-against-anxiety/
- Baumel A, Muench F, Edan S, Kane JM. Objective user engagement with mental health apps. *JMIR* 2019;21(9):e14567 — https://pmc.ncbi.nlm.nih.gov/articles/PMC6785720
- Impact of guidance on adherence in computerised mental-health interventions: meta-analysis. *Psychological Medicine* 52(2):229–240.
- Shim M, Mahaffey B, Bleidistel M, Gonzalez A. Scoping review of human-support factors in internet-based psychological interventions. *Clin Psychol Rev* 57.
- van Ballegooijen W, et al. Adherence to internet-based and face-to-face CBT for depression. *PLOS ONE* 2014;9(7):e100674 — https://pmc.ncbi.nlm.nih.gov/articles/PMC4100736

**Breathing, awe, exercise, sleep, music**
- Balban MY, et al. Brief structured respiration practices enhance mood and reduce physiological arousal. *Cell Reports Medicine* 2023;4(1):100895 — https://pmc.ncbi.nlm.nih.gov/articles/PMC9873947
- Sturm VE, et al. Big smile, small self: Awe walks promote prosocial positive emotions in older adults. *Emotion* 2020 — https://www.gbhi.org/news-publications/awe-walks-boost-emotional-well-being
- Noetel M, et al. Effect of exercise for depression: systematic review and network meta-analysis. *BMJ* 2024;384:e075847.
- Munro NR, et al. Effect of exercise on depression and anxiety symptoms: umbrella review with meta-meta-analysis. *Br J Sports Med* 2026 (in press) — https://researchonline.jcu.edu.au/91059
- Lee S, et al. Digital CBT for insomnia on depression and anxiety. *npj Digital Medicine* 2023;6:52 — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10039857/
- Lin W, et al. Efficacy of digital CBT for insomnia and depression. *PeerJ* 2023 (10.7717/peerj.16137) — https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10624170/
- Cao L, et al. Digital behavioural therapy for insomnia and depression/anxiety: IPD meta-analysis. medRxiv 2026 (preprint) — https://www.medrxiv.org/content/10.64898/2026.08.05.26359652.full.pdf
- Harney C, Johnson J, Bailes F, Havelka J. Is music listening an effective intervention for reducing anxiety? *Musicae Scientiae* 2022.
- Panteleeva Y, et al. Music for anxiety? Meta-analysis in non-clinical samples. *Psychology of Music* 2018;46(4):473–487.
- Music interventions for depressive symptoms: review. *Front Psychol* 2017;8:1109 (PMC5500733).
- NCCIH. Music and health: what the science says — https://www.nccih.nih.gov/health/providers/digest/music-and-health-science

**Behavioral activation, self-compassion, writing**
- Looking beyond depression: meta-analysis of behavioral activation. *Psychol Med* 2021;51(9):1491–1504 — https://pubmed.ncbi.nlm.nih.gov/32138802/
- Ciharova M, et al. CR, BA and CBT for adult depression: network meta-analysis. *J Consult Clin Psychol* 2021;89(6):563–574.
- Sturmey P. Behavioral activation is an evidence-based treatment for depression. *Behavior Modification* 2009.
- Han A, Kim TH. Effects of self-compassion interventions on depressive symptoms, anxiety, and stress. *Mindfulness* 2023 — https://pmc.ncbi.nlm.nih.gov/articles/PMC10239723/
- Ferrari M, et al. Self-compassion interventions and psychosocial outcomes: meta-analysis of RCTs. *Mindfulness* 2019;10:1455–1473.
- MacBeth A, Gumley A. 2012 (self-compassion correlations), cited in Stirling review — https://www.stir.ac.uk/research/hub/file/1386466
- Frattaroli J. Experimental disclosure and its moderators: a meta-analysis. *Psychological Bulletin* 2006.
- Expressive writing for anxiety, depression, stress: meta-analysis of 31 RCTs — https://www.simplypsychology.org/expressive-writing-for-anxiety.html
- Frontiers in Psychology 2023 (expressive-writing moderators) — https://frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2023.1192595/full
- Pavlacic JM, et al. 2019 expressive writing meta-analysis on PTSS/PTG/QoL, *Psychological Reports*? (check) — https://journals.sagepub.com/doi/10.1177/1089268019831645

**Loneliness and social connection**
- Masi CM, Chen HY, Hawkley LC, Cacioppo JT. A meta-analysis of interventions to reduce loneliness. *Pers Soc Psychol Rev* 2011;15(3):219–266 — https://pmc.ncbi.nlm.nih.gov/articles/PMC3865701
- The surprise of reaching out: appreciated more than we think. *J Pers Soc Psychol* 2023;124(4):754–771 — https://pubmed.ncbi.nlm.nih.gov/35816566/
- Kumar A, Epley N. Undervaluing gratitude. *Psychological Science* — https://news.uchicago.edu/story/people-underestimate-value-sending-letters-appreciation
- Kumar A, Epley N. Undersociality is unwise. *J Consumer Psychology* 2023;33(1):199–212.
- Epley N. *A Little More Social* (2026).

**Safety planning and coping apps**
- Stanley B, Brown GK, Brenner LA, et al. Safety Planning Intervention vs usual care in the ED. *JAMA Psychiatry* 2018;75(9):894–900 (doi 10.1001/jamapsychiatry.2018.1776) — https://www.npr.org/sections/health-shots/2018/07/11/628029412/
- ED-SAFE 2. *JAMA Psychiatry* 2023 (doi 10.1001/jamapsychiatry.2023.1304).
- Bush NE, Smolenski DJ, Denneson LM, et al. A Virtual Hope Box: RCT. *Psychiatric Services* 2017;68(4):330–336 — https://ps.psychiatryonline.org/doi/10.1176/appi.ps.201600283

**Single-session interventions**
- Schleider JL, Weisz JR. Little treatments, promising effects? *J Am Acad Child Adolesc Psychiatry* 2017;56(2):107–115 — https://dash.harvard.edu/handle/1/41292903
- Schleider JL, et al. Single-session interventions. *Annual Review of Clinical Psychology* (2025) — https://news.northwestern.edu/stories/2025/02/single-session-interventions-significantly-reduce-mental-health-issues-for-youth-and-adults

---

*End of brief. Suggested next step: hand this file to your research assistant with §8–9 as the task list.*
