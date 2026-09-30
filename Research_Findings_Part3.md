# Firefly Research Findings: Part 3
*Addressing Items 6 & 7 from Product Research Scope*

## 1. Evidence Table (Item 6)

| Intervention | Population | Design | N (Sample Size) | Outcome | Effect Size | Follow-up | Risk of Bias | Delivery Mode | Relevance to Offline App |
|---|---|---|---|---|---|---|---|---|---|
| **Cyclic Sighing (Breathing)** | Adults | RCT (Remote) | 114 | Positive affect, state anxiety | Greater than mindfulness | 1 month | Moderate | Unguided / Remote | **High.** Easily implemented offline; low risk; quick delivery. |
| **Behavioral Activation (Tiny Steps)** | Depression, Anxiety | Meta-analysis | >10,000 | Depression, activation | g = 0.83 (vs inactive) | Mixed | High (poor study quality) | Mostly Guided / F2F | **Moderate-High.** High efficacy but mostly tested guided. Needs adaptation to unguided offline. |
| **Self-Compassion** | Mixed / Distress | Meta-analysis | >5,000 | Rumination, depression | g = 0.66 to 1.37 | Mixed | High (publication bias) | Mixed | **Moderate.** Good potential but needs translation to safe offline prompts. |
| **Expressive Writing** | Healthy, Subclinical | Meta-analysis | >4,000 | Depression, anxiety, stress | d = 0.075 to 0.47 | Short-term | Moderate | Unguided | **Moderate-Low.** Small effects, potential for distress; needs careful guardrails. |
| **Loneliness (Cognitive/Beliefs)** | Lonely Adults | Meta-analysis | >1,000 | Loneliness reduction | Moderate | Mixed | High | Mostly Guided | **Moderate.** Promising basic science on reaching out, but app formats are untested. |
| **Safety Plan** | Veterans (ED) | Cohort / RCT | 1,640+ | Suicidal behavior | OR = 0.56 (reduction) | 6 months | Moderate | Clinician-delivered | **High.** Essential guardrail. Offline storage is ideal for privacy/access. |
| **Single-Session Interventions** | Youth & Adults | Meta-analysis | 10,508 | General mental health | g = 0.32 | Mixed | Low-Moderate | Mixed (incl. Digital) | **High.** Fits the "assume they won't return" offline app model perfectly. |
| **Awe Walk** | Healthy Older Adults | RCT | 52-60 | Positive emotions | Moderate | 8 weeks | High (small sample) | Unguided | **Low.** Evidence is preliminary and requires the user to go outdoors. |
| **Movement Snacks** | MDD | Network Meta | 14,000 | Depression | g = -0.42 to -0.62 | Mixed | High (low certainty) | Mixed | **Low-Moderate.** Efficacy tied to intensity. Unguided micro-doses untested. |
| **Sleep (dCBT-I / Wind-down)** | Insomnia | Meta-analysis | 2,504 | Insomnia, depression | SMD = -0.71 to -0.85 | Up to 6 months | Moderate | Automated/Unguided | **Moderate-High.** Strong digital evidence, but sleep restriction is risky unguided. |
| **Virtual Hope Box** | Suicidal Ideation | RCT | 118 | Coping self-efficacy | b = 2.41 to 2.99 | 12 weeks | Moderate | Unguided App | **High.** Proven efficacy in app format. Perfect for offline local storage. |
| **Music Therapy** | Anxiety, Depression | Meta-analysis | ~6,000 | Anxiety | d = -0.77 | Mixed | High (heterogeneity) | Unguided | **Moderate.** High efficacy but high friction to import local files on iOS/Android. |

---

## 2. Feature Priority Matrix (Item 7)

Based on the evidence grade, feasibility of an offline-only implementation, and safety risk, here is the prioritized list of features for the Firefly app.

### Tier 1: Core MVP
*High evidence for digital/app delivery, highly feasible offline, and low safety risk.*

* **A7 Safety Plan:** Essential for risk mitigation. While the strongest evidence is clinician-delivered, having an offline, instantly accessible template is a non-negotiable safety feature.
* **A2 Grounding & Breathing (Cyclic Sighing):** Supported by recent remote RCTs (Balban 2023) as highly effective for quick state-anxiety reduction. Perfect for a 2-minute offline session.
* **B6 Hope Box:** One of the few features explicitly validated as a standalone unguided app (Bush 2017) for improving coping self-efficacy. Easily uses local device storage for photos and text.
* **B1 One-Session Reset:** Supported by strong meta-analytic evidence for digital single-session interventions. Fits the low-retention reality (median 3.9% at 15 days).
* **A1 Check-in / Affect Labeling:** Required to drive the logic of the other features (state-matched suggestions). Low implementation cost and low risk.

### Tier 2: Fast Follows
*Moderate evidence, feasible offline, but requires careful adaptation from guided contexts or specific guardrails.*

* **A3 Tiny Steps (Behavioral Activation):** High evidence in face-to-face therapy, but untested as a purely unguided offline micro-dose. Very feasible, but needs a gentle, guilt-free UI.
* **B5 Wind-Down (Sleep):** Strong digital evidence (dCBT-I). Highly feasible, but must be restricted to gentler components (sleep diaries, wind-down routines) as unguided sleep-restriction therapy poses safety risks.
* **A4 Thought Untangler (Self-Compassion):** Good evidence for self-compassion, but risks causing frustration or rumination if the app's prompts lack nuance.
* **A6 / B2 Loneliness (Guess vs. Reality):** Basic science strongly supports the "surprise of reaching out" and belief testing. Feasible offline, but efficacy in an unguided app is a hypothesis.

### Tier 3: Later / Optional
*Lower/mixed evidence, harder to implement offline securely/safely, or higher risk of adverse effects.*

* **A5 Expressive Journaling:** Mixed evidence with generally small effects. Risk of triggering distress or rumination in highly distressed users if done without clinical support.
* **B4 Movement Snacks:** Unclear if 2-minute unguided "snacks" offer the same antidepressant effects as the prescribed-intensity exercises seen in RCTs. Potential liability/safety issues without supervision.
* **B7 Music Room:** High evidence for anxiety reduction, but purely offline local music storage creates high friction for users in the Spotify/Apple Music streaming era.
* **B3 Awe Walk:** Very small preliminary sample (n=52-60 healthy older adults). Hard to execute if the user is highly distressed or in a restrictive environment.
* **B8 Weekly Check-in Buddy:** High privacy implications. Moving data from an offline app to a third party (even a friend) breaks the "fully offline/private" promise and lacks direct RCT evidence.
